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
}