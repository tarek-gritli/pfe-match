export interface Company {
  name: string;
  logo?: string;
  industry: string;
  location: string;
  size: string;
  description?: string;
  foundedYear?: number;
  technologies: string[];
  website?: string;
  linkedinUrl?: string;
  contactEmail: string;
}

export interface CompanyProfileUpdate {
  company_name?: string;
  industry?: string;
  location: string;
  employee_count: string;  // or number, depending on backend
  founded_year?: number;
  company_description?: string;
  website?: string | null;
  linkedin_url?: string | null;
  technologies_used: string[];
}