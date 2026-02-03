import json
import httpx
from typing import List, Optional
from app.core.config import settings


async def calculate_match_score(
    student_skills: List[str],
    student_technologies: List[str],
    pfe_required_skills: List[str],
    pfe_title: str,
    pfe_description: Optional[str] = None,
    student_desired_role: Optional[str] = None
) -> dict:
    """
    Use OpenAI GPT to calculate a semantic match score between a student's profile
    and a PFE (internship) listing.
    
    The LLM understands relationships between technologies (e.g., Next.js relates to React/JavaScript)
    and can provide a more intelligent matching than simple keyword matching.
    
    Returns:
        dict with 'score' (0-100), 'explanation', and 'matched_skills'
    """
    if not settings.OPENAI_API_KEY:
        # Fallback to basic matching if no API key
        return _basic_match(student_skills, student_technologies, pfe_required_skills)
    
    # Combine student skills and technologies
    student_all_skills = list(set(student_skills + student_technologies))
    
    prompt = f"""You are an expert technical recruiter AI with comprehensive knowledge of ALL technologies, frameworks, libraries, and their relationships.

STUDENT PROFILE:
- Skills & Technologies: {', '.join(student_all_skills) if student_all_skills else 'None specified'}
- Desired Role: {student_desired_role or 'Not specified'}

PFE (INTERNSHIP) LISTING:
- Title: {pfe_title}
- Required Skills: {', '.join(pfe_required_skills) if pfe_required_skills else 'None specified'}
- Description: {pfe_description[:500] if pfe_description else 'Not provided'}

YOUR TASK: Use your deep knowledge of technology to INTELLIGENTLY match skills.

CRITICAL INSTRUCTIONS:
1. USE YOUR KNOWLEDGE - You know that:
   - Specific tools/frameworks IMPLY broader skill categories (PyTorch → Machine Learning, React → Frontend/Web Dev)
   - Technologies belong to ecosystems (Django implies Python proficiency)
   - Skills are transferable within domains (knowing React makes learning Vue easier)
   - YOU know ALL technology relationships - use that knowledge, don't just match strings!

2. SEMANTIC MATCHING EXAMPLES (apply this logic to ALL skills, not just these examples):
   - "Machine Learning" is satisfied by: PyTorch, TensorFlow, scikit-learn, Keras, XGBoost, Deep Learning, Neural Networks, etc.
   - "Data Science" is satisfied by: Pandas, NumPy, Matplotlib, Jupyter, R, Statistics, Data Analysis, etc.
   - "Web Development/Frontend" is satisfied by: React, Angular, Vue, Next.js, HTML, CSS, JavaScript, TypeScript, etc.
   - "Backend Development" is satisfied by: Django, Flask, FastAPI, Spring Boot, Express.js, Node.js, Laravel, etc.
   - "Mobile Development" is satisfied by: React Native, Flutter, Swift, Kotlin, iOS, Android, Xamarin, etc.
   - "Cloud Computing/DevOps" is satisfied by: AWS, Azure, GCP, Docker, Kubernetes, CI/CD, Terraform, etc.
   - "Databases" is satisfied by: PostgreSQL, MySQL, MongoDB, Redis, SQL, NoSQL, SQLite, etc.
   - "AI/Artificial Intelligence" is satisfied by: Machine Learning, Deep Learning, NLP, Computer Vision, LLMs, GPT, etc.
   - Technology ecosystems: Next.js→React→JavaScript, Angular→TypeScript, Django/Flask→Python, Spring Boot→Java
   
   IMPORTANT: These are just EXAMPLES. Apply the same semantic matching logic to ANY skill not listed here!

3. MATCHED_SKILLS rules:
   - List student skills that satisfy PFE requirements (directly or semantically)
   - Format: "StudentSkill (satisfies: PFE Requirement)"
   - Example: "TensorFlow (satisfies: Machine Learning)", "React (satisfies: Frontend Development)"

4. MISSING_SKILLS rules - THIS IS CRITICAL:
   - ONLY list PFE requirements the student GENUINELY cannot fulfill with their existing skills
   - If student has ANY skill that covers a requirement → that requirement is NOT missing
   - Example: Student has PyTorch → "Machine Learning" is NOT missing
   - Example: Student has React → "Frontend" or "Web Development" is NOT missing
   - Be intelligent - don't list something as missing if they clearly have it covered!

5. Scoring:
   - 85-100: Most requirements covered (directly or semantically)
   - 70-84: Good coverage with minor gaps
   - 50-69: Partial coverage, some learning needed
   - 30-49: Significant gaps
   - 0-29: Minimal alignment

Return ONLY valid JSON:
{{
    "score": <0-100>,
    "explanation": "<explain the skill matches you identified using your tech knowledge>",
    "matched_skills": ["<format: StudentSkill (satisfies: Requirement)>"],
    "missing_skills": ["<ONLY truly missing PFE requirements that student cannot cover>"],
    "recommendations": "<actionable advice>"
}}
"""

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                "https://api.openai.com/v1/chat/completions",
                headers={
                    "Authorization": f"Bearer {settings.OPENAI_API_KEY}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": "gpt-3.5-turbo",
                    "messages": [
                        {
                            "role": "system",
                            "content": "You are an expert technical recruiter with encyclopedic knowledge of ALL technologies and their relationships. Use your intelligence to match skills semantically - NEVER do simple string matching. You understand that PyTorch/TensorFlow users know Machine Learning, React/Vue developers know Frontend, Django developers know Python, etc. Apply this reasoning to ALL technologies. Missing skills must ONLY be requirements the student genuinely cannot fulfill with their existing knowledge. Return only valid JSON."
                        },
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    "temperature": 0.1,
                    "max_tokens": 800
                }
            )
            
            if response.status_code == 200:
                result = response.json()
                content = result["choices"][0]["message"]["content"]
                
                # Parse JSON from response (handle potential markdown code blocks)
                if "```json" in content:
                    content = content.split("```json")[1].split("```")[0]
                elif "```" in content:
                    content = content.split("```")[1].split("```")[0]
                
                parsed = json.loads(content.strip())
                
                # Ensure score is within bounds
                score = max(0, min(100, int(parsed.get("score", 0))))
                
                return {
                    "score": score,
                    "explanation": parsed.get("explanation", ""),
                    "matched_skills": parsed.get("matched_skills", []),
                    "missing_skills": parsed.get("missing_skills", []),
                    "recommendations": parsed.get("recommendations", "")
                }
            else:
                print(f"OpenAI API error: {response.status_code} - {response.text}")
                return _basic_match(student_skills, student_technologies, pfe_required_skills)
                
    except json.JSONDecodeError as e:
        print(f"Failed to parse LLM response as JSON: {e}")
        return _basic_match(student_skills, student_technologies, pfe_required_skills)
    except Exception as e:
        print(f"Match score calculation error: {e}")
        return _basic_match(student_skills, student_technologies, pfe_required_skills)


def _basic_match(
    student_skills: List[str],
    student_technologies: List[str],
    pfe_required_skills: List[str]
) -> dict:
    """
    Fallback basic matching algorithm when LLM is not available.
    Uses simple set intersection with case-insensitive comparison.
    """
    if not pfe_required_skills:
        return {
            "score": 50,
            "explanation": "No specific skills required for this position",
            "matched_skills": [],
            "missing_skills": [],
            "recommendations": "Apply and highlight your relevant experience"
        }
    
    # Normalize all skills to lowercase for comparison
    student_all = set(s.lower().strip() for s in (student_skills + student_technologies))
    required = set(s.lower().strip() for s in pfe_required_skills)
    
    # Find direct matches
    matched = student_all.intersection(required)
    missing = required - student_all
    
    # Calculate score based on percentage of required skills matched
    if len(required) > 0:
        match_percentage = (len(matched) / len(required)) * 100
        score = int(match_percentage)
    else:
        score = 50
    
    return {
        "score": score,
        "explanation": f"Matched {len(matched)} out of {len(required)} required skills",
        "matched_skills": list(matched),
        "missing_skills": list(missing),
        "recommendations": "Consider learning the missing skills to improve your chances"
    }


async def get_match_score_for_application(
    db_session,
    student_id: int,
    pfe_listing_id: int
) -> int:
    """
    Helper function to get just the match score for creating an application.
    Fetches student and PFE data from database and calculates the score.
    """
    from app.models import Student, PFEListing
    
    # Get student
    student = db_session.query(Student).filter(Student.id == student_id).first()
    if not student:
        return 0
    
    # Get PFE listing
    pfe = db_session.query(PFEListing).filter(PFEListing.id == pfe_listing_id).first()
    if not pfe:
        return 0
    
    # Calculate match
    result = await calculate_match_score(
        student_skills=student.skills or [],
        student_technologies=student.technologies or [],
        pfe_required_skills=pfe.skills or [],
        pfe_title=pfe.title,
        pfe_description=pfe.description,
        student_desired_role=student.desired_job_role
    )
    
    return result.get("score", 0)
