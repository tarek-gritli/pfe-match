import { Injectable, inject } from '@angular/core';
import { ApiService, ENDPOINTS } from '../api';
import { Student, StudentProfileUpdate } from '../models/student-profile.model';
import { Observable } from 'rxjs';

interface MessageResponse {
    message: string;
}

@Injectable({
    providedIn: 'root'
})
export class StudentService {
    private api = inject(ApiService);

    getProfile() {
        return this.api.get<Student>(ENDPOINTS.STUDENTS.PROFILE);
    }

    updateMyProfile(payload: StudentProfileUpdate): Observable<MessageResponse> {
    return this.api.put<MessageResponse>(
      ENDPOINTS.STUDENTS.UPDATE_PROFILE,
      payload
    );
  }

  getProfileImageUrl(path: string | undefined): string {
    return this.api.getAssetUrl(path);
}

/**
 * Download resume from path
 */
downloadResume(resumePath: string): Observable<Blob> {
  // Convert backslashes to forward slashes for URL
  const normalizedPath = resumePath.replace(/\\/g, '/');
  
  // Build the full URL using apiService
  const fullUrl = this.api.getAssetUrl(normalizedPath);
  
  return this.api.getBlobFromUrl(fullUrl);
}

/**
 * Get resume URL
 */
getResumeUrl(resumePath: string | undefined): string {
  if (!resumePath) return '';
  
  // Convert backslashes to forward slashes
  const normalizedPath = resumePath.replace(/\\/g, '/');
  
  return this.api.getAssetUrl(normalizedPath);
}
}