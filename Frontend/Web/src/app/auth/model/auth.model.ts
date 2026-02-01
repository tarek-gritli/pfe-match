// User types
export type UserType = 'student' | 'enterprise';

// ==================== REQUEST DTOs ====================

export interface StudentRegisterRequest {
    email: string;
    password: string;
    first_name: string;
    last_name: string;
}

export interface EnterpriseRegisterRequest {
    email: string;
    password: string;
    company_name: string;
    industry: string;
}

export interface LoginRequest {
    email: string;
    password: string;
}

// ==================== RESPONSE DTOs ====================

export interface AuthResponse {
    access_token: string;
    token_type: string;
    user_type: UserType;
    profile_completed: boolean;
}

export interface UserResponse {
    id: number;
    email: string;
    user_type: UserType;
    profile_completed: boolean;
    created_at: string;
}

export interface MessageResponse {
    message: string;
}

// ==================== PROFILE DTOs ====================

export interface StudentProfileUpdate {
    university?: string;
    short_bio?: string;
    profile_picture?: string;
    desired_job_role?: string;
    resume?: string;
    linkedin_url?: string;
    github_url?: string;
    portfolio_url?: string;
    skills?: string[];
    technologies?: string[];
}

export interface EnterpriseProfileUpdate {
    location?: string;
    employee_count?: string;
    company_description?: string;
    technologies_used?: string[];
    website?: string;
    founded_year?: number;
    company_logo?: string;
}

export interface StudentProfile {
    id: number;
    user_id: number;
    first_name: string;
    last_name: string;
    university?: string;
    short_bio?: string;
    profile_picture?: string;
    desired_job_role?: string;
    linkedin_url?: string;
    github_url?: string;
    portfolio_url?: string;
    skills?: string[];
    technologies?: string[];
    resume_url?: string;
    resume_parsed: boolean;
}

export interface EnterpriseProfile {
    id: number;
    user_id: number;
    company_name: string;
    industry: string;
    location?: string;
    employee_count?: string;
    company_description?: string;
    technologies_used?: string[];
    website?: string;
    founded_year?: number;
    company_logo?: string;
}

// ==================== RESUME UPLOAD ====================

export interface ResumeExtractedData {
    github_url?: string;
    linkedin_url?: string;
    skills: string[];
    technologies: string[];
}

export interface ResumeUploadResponse {
    message: string;
    resume_url: string;
    parsing_status: string;
    extracted_data?: ResumeExtractedData;
}

export interface ProfilePictureUploadResponse {
    message: string;
    profile_picture_url: string;
}

// ==================== AUTH STATE ====================

export interface AuthState {
    isAuthenticated: boolean;
    user: UserResponse | null;
    token: string | null;
    userType: UserType | null;
    profileCompleted: boolean;
}
