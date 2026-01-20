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
export interface StudentProfile {
  profileIntegrity: number;
  profile: {
    name: string;
    title: string;
    university: string;
    location: string;
    imageUrl: string;
    summary: string;
  };
  skills: NamedItem[];
  tools: NamedItem[];
  resume: Resume;
}
