import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject, throwError } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';

export interface ApplicantWithStatus {
  id: string;
  name: string;
  initials: string;
  email: string;
  university: string;
  fieldOfStudy: string;
  matchRate: number;
  avatarColor: string;
  appliedTo: string;
  pfeId: string;
  applicationDate: Date;
  status: 'pending' | 'reviewed' | 'shortlisted' | 'interview' | 'accepted' | 'rejected';
  skills: string[];
  resumeUrl?: string;
}

@Injectable({
  providedIn: 'root'
})
export class ApplicantService {
  private http = inject(HttpClient);
  private readonly API_URL = 'http://localhost:8000/api';

  // Cache pour les applicants
  private applicantsSubject = new BehaviorSubject<ApplicantWithStatus[]>([]);
  public applicants$ = this.applicantsSubject.asObservable();

  /**
   * Récupérer tous les applicants
   */
  getAllApplicants(): Observable<ApplicantWithStatus[]> {
    return this.http.get<ApplicantWithStatus[]>(`${this.API_URL}/applicants`).pipe(
      tap(applicants => this.applicantsSubject.next(applicants)),
      catchError(error => {
        console.error('Error fetching applicants:', error);
        return throwError(() => error);
      })
    );
  }

  /**
   * Récupérer les applicants par PFE ID
   */
  getApplicantsByPFE(pfeId: string): Observable<ApplicantWithStatus[]> {
    return this.http.get<ApplicantWithStatus[]>(
      `${this.API_URL}/pfe/listings/${pfeId}/applicants`
    ).pipe(
      catchError(error => {
        console.error('Error fetching applicants for PFE:', error);
        return throwError(() => error);
      })
    );
  }

  /**
   * Récupérer un applicant par ID
   */
  getApplicantById(id: string): Observable<ApplicantWithStatus> {
    return this.http.get<ApplicantWithStatus>(`${this.API_URL}/applicants/${id}`).pipe(
      catchError(error => {
        console.error('Error fetching applicant:', error);
        return throwError(() => error);
      })
    );
  }

  /**
   * Mettre à jour le statut d'un applicant
   */
  updateApplicantStatus(
    id: string,
    status: ApplicantWithStatus['status']
  ): Observable<ApplicantWithStatus> {
    return this.http.patch<ApplicantWithStatus>(
      `${this.API_URL}/applicants/${id}/status`,
      { status }
    ).pipe(
      tap(updatedApplicant => {
        const current = this.applicantsSubject.value;
        const updated = current.map(a =>
          a.id === id ? updatedApplicant : a
        );
        this.applicantsSubject.next(updated);
      }),
      catchError(error => {
        console.error('Error updating applicant status:', error);
        return throwError(() => error);
      })
    );
  }

  /**
   * Obtenir les applicants en cache
   */
  getCachedApplicants(): ApplicantWithStatus[] {
    return this.applicantsSubject.value;
  }

  /**
   * Rafraîchir les applicants
   */
  refreshApplicants(): void {
    this.getAllApplicants().subscribe();
  }
}
