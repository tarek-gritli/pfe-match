export type PFEStatus = 'open' | 'closed';

export interface PFEListing {
  id: string;
  title: string;
  status: PFEStatus;
  category: string;
  duration: string;
  skills: string[];
  applicantCount: number;
  description?: string;
  department?: string;
  postedDate?: Date;
  deadline?: Date;
}
export interface Applicant {
  id: string;
  name: string;
  initials: string;
  appliedTo: string;
  matchRate: number;
  avatarColor: string;
  email?: string;
  applicationDate?: Date;
  university?: string;
  fieldOfStudy?: string;
  skills?: string[];
  resumeUrl?: string;
}

export interface DashboardStatistics {
  activePFEs: number;
  totalApplicants: number;
  topApplicants: number;
  avgMatchRate: number;
}

export interface CompanyInfo {
  name: string;
  description: string;
  logoUrl: string;
  website?: string;
  industry?: string;
  companySize?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface PFEFilters {
  status?: PFEStatus;
  category?: string;
  skills?: string[];
  searchQuery?: string;
  sortBy?: 'date' | 'applicants' | 'title';
  sortDirection?: 'asc' | 'desc';
}

export type ApplicationStatus =
  | 'pending'
  | 'reviewed'
  | 'shortlisted'
  | 'interview'
  | 'accepted'
  | 'rejected';

export interface ApplicantWithStatus extends Applicant {
  status: ApplicationStatus;
  reviewerNotes?: string;
  lastUpdated?: Date;
}
