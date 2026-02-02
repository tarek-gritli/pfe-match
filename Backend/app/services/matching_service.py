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
    
    prompt = f"""You are an expert recruiter AI that calculates match scores between candidates and job/internship positions.

STUDENT PROFILE:
- Skills & Technologies: {', '.join(student_all_skills) if student_all_skills else 'None specified'}
- Desired Role: {student_desired_role or 'Not specified'}

PFE (INTERNSHIP) LISTING:
- Title: {pfe_title}
- Required Skills: {', '.join(pfe_required_skills) if pfe_required_skills else 'None specified'}
- Description: {pfe_description[:500] if pfe_description else 'Not provided'}

IMPORTANT MATCHING RULES:
1. Consider semantic relationships between technologies:
   - Next.js relates to React, JavaScript, Node.js
   - Angular relates to TypeScript, JavaScript
   - Django relates to Python
   - Spring Boot relates to Java
   - React Native relates to React, JavaScript, Mobile Development
   - Docker relates to DevOps, containerization
   - AWS/Azure/GCP relate to Cloud Computing
   
2. Consider skill levels and transferability:
   - Strong JavaScript skills are valuable for TypeScript positions
   - Python developers can often adapt to Django/Flask
   - Frontend developers with React can learn Vue.js quickly

3. Weight the scoring:
   - Direct match (exact skill): High weight
   - Related technology (same ecosystem): Medium weight
   - Transferable skill (can learn quickly): Low weight
   - Soft skills matching: Consider for overall fit

Calculate a match score from 0 to 100:
- 90-100: Excellent match, student has most required skills
- 70-89: Good match, student has many relevant skills
- 50-69: Moderate match, some skill overlap
- 30-49: Weak match, few matching skills
- 0-29: Poor match, minimal skill alignment

Return ONLY valid JSON with this structure:
{{
    "score": <number 0-100>,
    "explanation": "<brief explanation of the match>",
    "matched_skills": ["<list of matched or related skills>"],
    "missing_skills": ["<list of important missing skills>"],
    "recommendations": "<brief recommendation for the student>"
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
                            "content": "You are an expert recruiter AI. Calculate accurate match scores based on skill alignment and technology relationships. Return only valid JSON."
                        },
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    "temperature": 0.2,
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
