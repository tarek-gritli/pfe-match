import re
from typing import Optional
from app.schemas import ResumeExtractedData

# Common skills and technologies to detect
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


def extract_skills(text: str) -> list[str]:
    """Extract skills from text"""
    text_lower = text.lower()
    found_skills = []
    
    for skill in COMMON_SKILLS:
        # Use word boundaries to avoid partial matches
        pattern = r'\b' + re.escape(skill) + r'\b'
        if re.search(pattern, text_lower):
            # Capitalize first letter of each word
            found_skills.append(skill.title())
    
    return list(set(found_skills))  # Remove duplicates


def extract_technologies(text: str) -> list[str]:
    """Extract technologies from text"""
    text_lower = text.lower()
    found_techs = []
    
    for tech in COMMON_TECHNOLOGIES:
        pattern = r'\b' + re.escape(tech) + r'\b'
        if re.search(pattern, text_lower):
            found_techs.append(tech.title())
    
    return list(set(found_techs))


def parse_resume_text(text: str) -> ResumeExtractedData:
    """Parse resume text and extract relevant information"""
    return ResumeExtractedData(
        github_url=extract_github_url(text),
        linkedin_url=extract_linkedin_url(text),
        skills=extract_skills(text),
        technologies=extract_technologies(text)
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


def parse_resume(file_content: bytes) -> ResumeExtractedData:
    """
    Parse resume PDF and extract information.
    Returns extracted GitHub URL, LinkedIn URL, skills, and technologies.
    """
    text = extract_text_from_pdf(file_content)
    return parse_resume_text(text)
