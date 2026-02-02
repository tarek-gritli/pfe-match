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

}