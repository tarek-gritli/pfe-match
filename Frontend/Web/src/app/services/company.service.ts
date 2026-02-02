import { Injectable, inject } from '@angular/core';
import { ApiService, ENDPOINTS } from '../api';
import { Company, CompanyProfileUpdate } from '../models/company-profile.model';
import { Observable } from 'rxjs';

interface MessageResponse {
    message: string;
}

@Injectable({
    providedIn: 'root'
})
export class CompanyService {
    private api = inject(ApiService);

    getProfile() {
        return this.api.get<Company>(ENDPOINTS.ENTERPRISES.PROFILE);
    }

    updateMyProfile(payload: CompanyProfileUpdate): Observable<MessageResponse> {
    return this.api.put<MessageResponse>(
      ENDPOINTS.ENTERPRISES.UPDATE_PROFILE,
      payload
    );
  }

    getProfileImageUrl(path: string | undefined): string {
    return this.api.getAssetUrl(path);
}
}