import re
import json
import httpx
from typing import Optional, List
from app.schemas import ResumeExtractedData
from app.core.config import settings


async def extract_with_llm(text: str) -> dict:
    """
    Use OpenAI GPT to extract structured data from CV text.
    Returns skills, technologies, and other relevant information.
    """
    if not settings.OPENAI_API_KEY:
        return {}
    
    prompt = """Analyze the following CV/resume text and extract the information in JSON format.
Extract:
1. "skills": List of technical and soft skills (programming languages, frameworks, tools, methodologies, soft skills)
2. "technologies": List of specific technologies, frameworks, and tools mentioned
3. "experience_years": Estimated years of professional experience (number or null)
4. "education_level": Highest education level (e.g., "Bachelor's", "Master's", "PhD", or null)
5. "languages": List of spoken/written languages mentioned

Be thorough and extract ALL skills mentioned, including:
- Programming languages (Python, JavaScript, Java, etc.)
- Frameworks (React, Angular, Django, Spring, etc.)
- Databases (PostgreSQL, MongoDB, MySQL, etc.)
- Cloud platforms (AWS, Azure, GCP, etc.)
- DevOps tools (Docker, Kubernetes, Jenkins, etc.)
- Soft skills (Leadership, Communication, Problem-solving, etc.)

Return ONLY valid JSON, no additional text.

CV Text:
{text}
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
                            "content": "You are a professional CV/resume parser. Extract information accurately and return only valid JSON."
                        },
                        {
                            "role": "user",
                            "content": prompt.format(text=text[:8000])  # Limit text length
                        }
                    ],
                    "temperature": 0.1,
                    "max_tokens": 1500
                }
            )
            
            if response.status_code == 200:
                result = response.json()
                content = result["choices"][0]["message"]["content"]
                # Parse JSON from response
                # Handle potential markdown code blocks
                if "```json" in content:
                    content = content.split("```json")[1].split("```")[0]
                elif "```" in content:
                    content = content.split("```")[1].split("```")[0]
                return json.loads(content.strip())
            else:
                print(f"OpenAI API error: {response.status_code} - {response.text}")
                return {}
    except json.JSONDecodeError as e:
        print(f"Failed to parse LLM response as JSON: {e}")
        return {}
    except Exception as e:
        print(f"LLM extraction error: {e}")
        return {}


def extract_with_llm_sync(text: str) -> dict:
    """
    Synchronous version of LLM extraction for non-async contexts.
    """
    import asyncio
    try:
        loop = asyncio.get_event_loop()
        if loop.is_running():
            # If we're in an async context, create a new task
            import concurrent.futures
            with concurrent.futures.ThreadPoolExecutor() as pool:
                future = pool.submit(asyncio.run, extract_with_llm(text))
                return future.result()
        else:
            return loop.run_until_complete(extract_with_llm(text))
    except RuntimeError:
        return asyncio.run(extract_with_llm(text))


def extract_github_url(text: str) -> Optional[str]:
    """Extract GitHub URL from text"""
    # Match github.com/username or github.com/username/repo
    pattern = r'(?:https?://)?(?:www\.)?github\.com/[\w\-]+(?:/[\w\-\.]+)?'
    match = re.search(pattern, text, re.IGNORECASE)
    if match:
        url = match.group(0)
        if not url.startswith('http'):
            url = 'https://' + url
        return url
    return None


def extract_linkedin_url(text: str) -> Optional[str]:
    """Extract LinkedIn URL from text"""
    # Match linkedin.com/in/username
    pattern = r'(?:https?://)?(?:www\.)?linkedin\.com/in/[\w\-]+'
    match = re.search(pattern, text, re.IGNORECASE)
    if match:
        url = match.group(0)
        if not url.startswith('http'):
            url = 'https://' + url
        return url
    return None


# Fallback: Common skills and technologies for regex-based extraction
COMMON_SKILLS = [
    "python", "javascript", "typescript", "java", "c++", "c#", "ruby", "go", "rust",
    "php", "swift", "kotlin", "scala", "r", "matlab", "sql", "html", "css",
    "react", "angular", "vue", "node.js", "express", "django", "flask", "fastapi",
    "spring", "spring boot", ".net", "rails", "laravel", "next.js", "nuxt.js",
    "machine learning", "deep learning", "data science", "data analysis",
    "tensorflow", "pytorch", "keras", "scikit-learn", "pandas", "numpy",
    "docker", "kubernetes", "aws", "azure", "gcp", "git", "jenkins", "ci/cd",
    "mongodb", "postgresql", "mysql", "redis", "elasticsearch", "graphql",
    "rest api", "microservices", "agile", "scrum", "jira", "linux", "bash"
]

COMMON_TECHNOLOGIES = [
    "react", "angular", "vue.js", "node.js", "express.js", "django", "flask",
    "fastapi", "spring boot", "docker", "kubernetes", "aws", "azure", "gcp",
    "mongodb", "postgresql", "mysql", "redis", "elasticsearch", "kafka",
    "rabbitmq", "nginx", "jenkins", "github actions", "gitlab ci", "terraform",
    "ansible", "prometheus", "grafana", "tensorflow", "pytorch", "jupyter"
]


def extract_skills_regex(text: str) -> List[str]:
    """Fallback: Extract skills using regex pattern matching"""
    text_lower = text.lower()
    found_skills = []
    
    for skill in COMMON_SKILLS:
        pattern = r'\b' + re.escape(skill) + r'\b'
        if re.search(pattern, text_lower):
            found_skills.append(skill.title())
    
    return list(set(found_skills))


def extract_technologies_regex(text: str) -> List[str]:
    """Fallback: Extract technologies using regex pattern matching"""
    text_lower = text.lower()
    found_techs = []
    
    for tech in COMMON_TECHNOLOGIES:
        pattern = r'\b' + re.escape(tech) + r'\b'
        if re.search(pattern, text_lower):
            found_techs.append(tech.title())
    
    return list(set(found_techs))


async def parse_resume_text_async(text: str) -> ResumeExtractedData:
    """Parse resume text and extract relevant information using LLM"""
    # Extract URLs using regex (reliable)
    github_url = extract_github_url(text)
    linkedin_url = extract_linkedin_url(text)
    
    # Try LLM extraction first
    if settings.OPENAI_API_KEY:
        llm_data = await extract_with_llm(text)
        if llm_data:
            skills = llm_data.get("skills", [])
            technologies = llm_data.get("technologies", [])
            
            # Ensure lists are properly formatted
            if isinstance(skills, list):
                skills = [str(s).strip() for s in skills if s]
            else:
                skills = []
            
            if isinstance(technologies, list):
                technologies = [str(t).strip() for t in technologies if t]
            else:
                technologies = []
            
            return ResumeExtractedData(
                github_url=github_url,
                linkedin_url=linkedin_url,
                skills=skills,
                technologies=technologies
            )
    
    # Fallback to regex-based extraction
    return ResumeExtractedData(
        github_url=github_url,
        linkedin_url=linkedin_url,
        skills=extract_skills_regex(text),
        technologies=extract_technologies_regex(text)
    )


def parse_resume_text(text: str) -> ResumeExtractedData:
    """Synchronous version: Parse resume text and extract relevant information"""
    # Extract URLs using regex (reliable)
    github_url = extract_github_url(text)
    linkedin_url = extract_linkedin_url(text)
    
    # Try LLM extraction first
    if settings.OPENAI_API_KEY:
        llm_data = extract_with_llm_sync(text)
        if llm_data:
            skills = llm_data.get("skills", [])
            technologies = llm_data.get("technologies", [])
            
            # Ensure lists are properly formatted
            if isinstance(skills, list):
                skills = [str(s).strip() for s in skills if s]
            else:
                skills = []
            
            if isinstance(technologies, list):
                technologies = [str(t).strip() for t in technologies if t]
            else:
                technologies = []
            
            return ResumeExtractedData(
                github_url=github_url,
                linkedin_url=linkedin_url,
                skills=skills,
                technologies=technologies
            )
    
    # Fallback to regex-based extraction
    return ResumeExtractedData(
        github_url=github_url,
        linkedin_url=linkedin_url,
        skills=extract_skills_regex(text),
        technologies=extract_technologies_regex(text)
    )


def extract_text_from_pdf(file_content: bytes) -> str:
    """
    Extract text from PDF file.
    Requires PyPDF2 or pdfplumber library.
    """
    try:
        import pdfplumber
        from io import BytesIO
        
        text = ""
        with pdfplumber.open(BytesIO(file_content)) as pdf:
            for page in pdf.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"
        return text
    except ImportError:
        # Fallback to PyPDF2 if pdfplumber is not available
        try:
            from PyPDF2 import PdfReader
            from io import BytesIO
            
            reader = PdfReader(BytesIO(file_content))
            text = ""
            for page in reader.pages:
                text += page.extract_text() + "\n"
            return text
        except ImportError:
            raise ImportError("Please install pdfplumber or PyPDF2: pip install pdfplumber")
    except Exception as e:
        raise Exception(f"Error extracting text from PDF: {str(e)}")


async def parse_resume_async(file_content: bytes) -> ResumeExtractedData:
    """
    Async version: Parse resume PDF and extract information using LLM.
    Returns extracted GitHub URL, LinkedIn URL, skills, and technologies.
    """
    text = extract_text_from_pdf(file_content)
    return await parse_resume_text_async(text)


def parse_resume(file_content: bytes) -> ResumeExtractedData:
    """
    Parse resume PDF and extract information.
    Returns extracted GitHub URL, LinkedIn URL, skills, and technologies.
    Uses LLM if OPENAI_API_KEY is configured, otherwise falls back to regex.
    """
    text = extract_text_from_pdf(file_content)
    return parse_resume_text(text)
