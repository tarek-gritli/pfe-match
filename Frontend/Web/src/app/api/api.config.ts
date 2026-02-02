// API Configuration
export const API_CONFIG = {
    BASE_URL: 'http://localhost:8000',
    TIMEOUT: 30000,
    VERSION: 'v1'
};

// API Endpoints
export const ENDPOINTS = {
    // Auth
    AUTH: {
        REGISTER_STUDENT: '/auth/register/student',
        REGISTER_ENTERPRISE: '/auth/register/enterprise',
        LOGIN: '/auth/login',
    },

    // Students
    STUDENTS: {
        PROFILE: '/students/me',
        UPDATE_PROFILE: '/students/me/profile',
        UPLOAD_RESUME: '/students/me/resume',
        UPLOAD_PROFILE_PICTURE: '/students/me/profile-picture',
    },

    // Enterprises
    ENTERPRISES: {
        PROFILE: '/enterprises/me',
        UPDATE_PROFILE: '/enterprises/me/profile',
        UPLOAD_LOGO: '/enterprises/me/logo',
    },

    // PFE Listings
    PFE: {
        EXPLORE: '/api/pfe/explore',
        LISTINGS: '/api/pfe/listings',
    }
};
