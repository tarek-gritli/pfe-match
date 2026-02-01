import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { API_CONFIG } from './api.config';

export interface ApiOptions {
    headers?: HttpHeaders | { [header: string]: string | string[] };
    params?: HttpParams | { [param: string]: string | string[] };
    withCredentials?: boolean;
}

export interface ApiError {
    message: string;
    status?: number;
    detail?: string;
}

@Injectable({
    providedIn: 'root'
})
export class ApiService {
    private readonly baseUrl: string = API_CONFIG.BASE_URL;

    constructor(private readonly http: HttpClient) { }

    /**
     * Build full URL from endpoint
     */
    private buildUrl(endpoint: string): string {
        return `${this.baseUrl}${endpoint}`;
    }

    /**
     * Get default headers with auth token
     */
    private getAuthHeaders(): HttpHeaders {
        const token = localStorage.getItem('pfe_match_token');
        let headers = new HttpHeaders({
            'Content-Type': 'application/json'
        });

        if (token) {
            headers = headers.set('Authorization', `Bearer ${token}`);
        }

        return headers;
    }

    /**
     * Handle HTTP errors
     */
    private handleError(error: HttpErrorResponse): Observable<never> {
        let errorMessage = 'An unknown error occurred';

        if (error.error instanceof ErrorEvent) {
            errorMessage = error.error.message;
        } else {
            errorMessage = error.error?.detail || error.message || errorMessage;
        }

        console.error('API Error:', errorMessage);
        return throwError(() => new Error(errorMessage));
    }

    /**
     * GET request
     */
    get<TResponse>(endpoint: string, options?: ApiOptions): Observable<TResponse> {
        return this.http.get<TResponse>(this.buildUrl(endpoint), {
            headers: this.getAuthHeaders(),
            ...options
        }).pipe(catchError(this.handleError));
    }

    /**
     * POST request with JSON body
     */
    post<TResponse, TBody = unknown>(endpoint: string, body: TBody, options?: ApiOptions): Observable<TResponse> {
        return this.http.post<TResponse>(this.buildUrl(endpoint), body, {
            headers: this.getAuthHeaders(),
            ...options
        }).pipe(catchError(this.handleError));
    }

    /**
     * POST request without auth (for login/register)
     */
    postPublic<TResponse, TBody = unknown>(endpoint: string, body: TBody): Observable<TResponse> {
        return this.http.post<TResponse>(this.buildUrl(endpoint), body, {
            headers: new HttpHeaders({ 'Content-Type': 'application/json' })
        }).pipe(catchError(this.handleError));
    }

    /**
     * POST form data (for file uploads)
     */
    postFormData<TResponse>(endpoint: string, formData: any): Observable<TResponse> {
        const token = localStorage.getItem('pfe_match_token');
        let headers = new HttpHeaders();

        if (token) {
            headers = headers.set('Authorization', `Bearer ${token}`);
        }
        return this.http.post<TResponse>(this.buildUrl(endpoint), formData, { headers })
            .pipe(catchError(this.handleError));
    }

    /**
     * PUT request
     */
    put<TResponse, TBody = unknown>(endpoint: string, body: TBody, options?: ApiOptions): Observable<TResponse> {
        return this.http.put<TResponse>(this.buildUrl(endpoint), body, {
            headers: this.getAuthHeaders(),
            ...options
        }).pipe(catchError(this.handleError));
    }

    /**
     * PATCH request
     */
    patch<TResponse, TBody = unknown>(endpoint: string, body: TBody, options?: ApiOptions): Observable<TResponse> {
        return this.http.patch<TResponse>(this.buildUrl(endpoint), body, {
            headers: this.getAuthHeaders(),
            ...options
        }).pipe(catchError(this.handleError));
    }

    /**
     * DELETE request
     */
    delete<TResponse>(endpoint: string, options?: ApiOptions): Observable<TResponse> {
        return this.http.delete<TResponse>(this.buildUrl(endpoint), {
            headers: this.getAuthHeaders(),
            ...options
        }).pipe(catchError(this.handleError));
    }

    /**
     * POST for URL-encoded form data (used for OAuth2 login)
     */
    postUrlEncoded<TResponse>(endpoint: string, body: URLSearchParams): Observable<TResponse> {
        return this.http.post<TResponse>(this.buildUrl(endpoint), body.toString(), {
            headers: new HttpHeaders({ 'Content-Type': 'application/x-www-form-urlencoded' })
        }).pipe(catchError(this.handleError));
    }

    /**
     * Complete student profile after registration
     * Sends all profile data including optional files in a single request
     */
    completeStudentProfile(
        profileData: {
            desired_job_role: string;
            university: string;
            bio: string;
            resumeFile?: File;
            profilePicture?: File;
        }
    ): Observable<any> {
        const formData = new FormData();

        // Add required text fields
        formData.append('desired_job_role', profileData.desired_job_role);
        formData.append('university', profileData.university);
        formData.append('bio', profileData.bio);

        // Add optional files
        if (profileData.resumeFile) {
            formData.append('resume', profileData.resumeFile, profileData.resumeFile.name);
        }
        if (profileData.profilePicture) {
            formData.append('profile_picture', profileData.profilePicture, profileData.profilePicture.name);
        }

        return this.postFormData('/students/me/profile', formData);
    }
}
