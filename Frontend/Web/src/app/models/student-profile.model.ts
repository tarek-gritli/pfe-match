// Represents a simple named item (for skills/tools)
export interface NamedItem {
  name: string;
}

// Resume metadata
export interface Resume {
  filename: string;
  lastUpdated: string;
  size: string;
}

// Full student profile structure returned by backend
export interface Student {
  firstName: string;
  lastName: string;
  profileImage?: string;
  title?: string;
  university: string;
  fieldOfStudy: string;
  bio: string;
  skills: string[];
  technologies: string[];
  linkedinUrl?: string;
  githubUrl?: string;
  customLinkUrl?: string;
  customLinkLabel?: string;
  resumeName?: string;
  resumeUploadDate?: string;
}

export interface StudentProfileUpdate {
  university?: string;
  short_bio?: string;
  desired_job_role?: string;
  linkedin_url?: string;
  github_url?: string;
  portfolio_url?: string;
  skills?: string[];
  technologies?: string[];
}