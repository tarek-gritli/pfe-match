import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, tap, catchError, throwError, Subject } from 'rxjs';
import { Router } from '@angular/router';
import { ApiService, ENDPOINTS } from '../../api';
import {
    AuthResponse,
    LoginRequest,
    StudentRegisterRequest,
    EnterpriseRegisterRequest,
    AuthState,
    UserType,
    StudentProfile,
    EnterpriseProfile,
    StudentProfileUpdate,
    EnterpriseProfileUpdate,
    ResumeUploadResponse,
    ProfilePictureUploadResponse,
    MessageResponse
} from '../model/auth.model';

@Injectable({
    providedIn: 'root'
})
export class AuthService {
    private readonly TOKEN_KEY = 'pfe_match_token';
    private readonly USER_TYPE_KEY = 'pfe_match_user_type';
    private readonly PROFILE_COMPLETED_KEY = 'pfe_match_profile_completed';
    private readonly EMAIL_KEY = 'pfe_match_email';

    private authState = new BehaviorSubject<AuthState>({
        isAuthenticated: false,
        user: null,
        token: null,
        userType: null,
        profileCompleted: false
    });

    authState$ = this.authState.asObservable();

    // Subject to notify components when profile is updated
    private profileUpdated = new Subject<void>();
    profileUpdated$ = this.profileUpdated.asObservable();

    constructor(
        private api: ApiService,
        private router: Router
    ) {
        this.loadStoredAuth();
    }

    /**
     * Notify components that profile has been updated
     */
    notifyProfileUpdated(): void {
        this.profileUpdated.next();
    }

    /**
     * Load authentication state from localStorage
     */
    private loadStoredAuth(): void {
        const token = localStorage.getItem(this.TOKEN_KEY);
        const userType = localStorage.getItem(this.USER_TYPE_KEY) as UserType | null;
        const profileCompleted = localStorage.getItem(this.PROFILE_COMPLETED_KEY) === 'true';
        const email = localStorage.getItem(this.EMAIL_KEY);

        if (token) {
            this.authState.next({
                isAuthenticated: true,
                user: null,
                token,
                userType,
                profileCompleted
            });
        }
    }

    /**
     * Get current auth state
     */
    get currentAuthState(): AuthState {
        return this.authState.value;
    }

    /**
     * Check if user is authenticated
     */
    get isAuthenticated(): boolean {
        return this.authState.value.isAuthenticated;
    }

    /**
     * Get current token
     */
    get token(): string | null {
        return this.authState.value.token;
    }

    /**
     * Register a new student
     */
    registerStudent(data: StudentRegisterRequest): Observable<AuthResponse> {
        return this.api.postPublic<AuthResponse>(ENDPOINTS.AUTH.REGISTER_STUDENT, data).pipe(
            tap((response: AuthResponse) => this.handleAuthResponse(response, data.email)),
            catchError(error => this.handleError(error))
        );
    }

    /**
     * Register a new enterprise
     */
    registerEnterprise(data: EnterpriseRegisterRequest): Observable<AuthResponse> {
        return this.api.postPublic<AuthResponse>(ENDPOINTS.AUTH.REGISTER_ENTERPRISE, data).pipe(
            tap((response: AuthResponse) => this.handleAuthResponse(response, data.email)),
            catchError(error => this.handleError(error))
        );
    }

    /**
     * Login user (works for both student and enterprise)
     */
    login(data: LoginRequest): Observable<AuthResponse> {
        return this.api.postPublic<AuthResponse>(ENDPOINTS.AUTH.LOGIN, data).pipe(
            tap((response: AuthResponse) => this.handleAuthResponse(response, data.email)),
            catchError(error => this.handleError(error))
        );
    }

    /**
     * Handle successful authentication response
     */
    private handleAuthResponse(response: AuthResponse, email: string): void {
        localStorage.setItem(this.TOKEN_KEY, response.access_token);
        localStorage.setItem(this.USER_TYPE_KEY, response.user_type);
        localStorage.setItem(this.PROFILE_COMPLETED_KEY, String(response.profile_completed));
        localStorage.setItem(this.EMAIL_KEY, email); 

        this.authState.next({
            isAuthenticated: true,
            user: null,
            token: response.access_token,
            userType: response.user_type,
            profileCompleted: response.profile_completed
        });
    }

    /**
     * Logout user
     */
    logout(): void {
        localStorage.removeItem(this.TOKEN_KEY);
        localStorage.removeItem(this.USER_TYPE_KEY);
        localStorage.removeItem(this.PROFILE_COMPLETED_KEY);
        localStorage.removeItem(this.EMAIL_KEY);

        this.authState.next({
            isAuthenticated: false,
            user: null,
            token: null,
            userType: null,
            profileCompleted: false
        });

        this.router.navigate(['/login']);
    }

    /**
     * Get student profile
     */
    getStudentProfile(): Observable<StudentProfile> {
        return this.api.get<StudentProfile>(ENDPOINTS.STUDENTS.PROFILE).pipe(
            catchError(error => this.handleError(error))
        );
    }

    /**
     * Update student profile
     */
    updateStudentProfile(data: StudentProfileUpdate): Observable<MessageResponse> {
        return this.api.put<MessageResponse>(ENDPOINTS.STUDENTS.UPDATE_PROFILE, data).pipe(
            tap(() => {
                localStorage.setItem(this.PROFILE_COMPLETED_KEY, 'true');
                this.authState.next({
                    ...this.authState.value,
                    profileCompleted: true
                });
            }),
            catchError(error => this.handleError(error))
        );
    }

    /**
     * Upload student resume
     */
    uploadResume(file: File): Observable<ResumeUploadResponse> {
        const formData = new FormData();
        formData.append('file', file);

        return this.api.postFormData<ResumeUploadResponse>(ENDPOINTS.STUDENTS.UPLOAD_RESUME, formData).pipe(
            catchError(error => this.handleError(error))
        );
    }

    /**
     * Upload student profile picture
     */
    uploadStudentProfilePicture(file: File): Observable<ProfilePictureUploadResponse> {
        const formData = new FormData();
        formData.append('file', file);

        return this.api.postFormData<ProfilePictureUploadResponse>(ENDPOINTS.STUDENTS.UPLOAD_PROFILE_PICTURE, formData).pipe(
            catchError(error => this.handleError(error))
        );
    }

    /**
     * Get enterprise profile
     */
    getEnterpriseProfile(): Observable<EnterpriseProfile> {
        return this.api.get<EnterpriseProfile>(ENDPOINTS.ENTERPRISES.PROFILE).pipe(
            catchError(error => this.handleError(error))
        );
    }

    /**
     * Update enterprise profile
     */
    updateEnterpriseProfile(data: EnterpriseProfileUpdate): Observable<MessageResponse> {
        return this.api.put<MessageResponse>(ENDPOINTS.ENTERPRISES.UPDATE_PROFILE, data).pipe(
            tap(() => {
                localStorage.setItem(this.PROFILE_COMPLETED_KEY, 'true');
                this.authState.next({
                    ...this.authState.value,
                    profileCompleted: true
                });
            }),
            catchError(error => this.handleError(error))
        );
    }

    /**
     * Upload company logo
     */
    uploadCompanyLogo(file: File): Observable<ProfilePictureUploadResponse> {
        const formData = new FormData();
        formData.append('file', file);

        return this.api.postFormData<ProfilePictureUploadResponse>(ENDPOINTS.ENTERPRISES.UPLOAD_LOGO, formData).pipe(
            catchError(error => this.handleError(error))
        );
    }

    /**
     * Handle HTTP errors
     */
    private handleError(error: any): Observable<never> {
        let errorMessage = 'An error occurred';

        if (error.error?.detail) {
            errorMessage = error.error.detail;
        } else if (error.error?.message) {
            errorMessage = error.error.message;
        } else if (error.status === 401) {
            errorMessage = 'Invalid credentials';
            this.logout();
        } else if (error.status === 400) {
            errorMessage = 'Invalid request';
        } else if (error.status === 403) {
            errorMessage = 'Access denied';
        } else if (error.status === 0) {
            errorMessage = 'Unable to connect to server';
        }

        return throwError(() => new Error(errorMessage));
    }
}
