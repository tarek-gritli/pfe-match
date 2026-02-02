import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject, throwError } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';
import { PFEListing, DashboardStatistics } from '../common/interfaces/interface';

@Injectable({
  providedIn: 'root'
})
export class PFEService {
  private http = inject(HttpClient);
  private readonly API_URL = 'http://localhost:8000/api';

  // BehaviorSubject pour garder l'état en mémoire (cache)
  private pfeListingsSubject = new BehaviorSubject<PFEListing[]>([]);
  public pfeListings$ = this.pfeListingsSubject.asObservable();

  // ============================================
  // GET - Récupérer les données
  // ============================================

  /**
   * Récupérer toutes les PFE listings
   */
  getPFEListings(): Observable<PFEListing[]> {
    return this.http.get<PFEListing[]>(`${this.API_URL}/pfe/listings`).pipe(
      tap(listings => this.pfeListingsSubject.next(listings)), // Mise à jour du cache
      catchError(error => {
        console.error('Error fetching PFE listings:', error);
        return throwError(() => error);
      })
    );
  }

  /**
   * Récupérer une PFE par ID
   */
  getPFEById(id: string): Observable<PFEListing> {
    return this.http.get<PFEListing>(`${this.API_URL}/pfe/listings/${id}`).pipe(
      catchError(error => {
        console.error('Error fetching PFE:', error);
        return throwError(() => error);
      })
    );
  }

  /**
   * Récupérer les statistiques du dashboard
   */
  getStatistics(): Observable<DashboardStatistics> {
    return this.http.get<DashboardStatistics>(`${this.API_URL}/dashboard/statistics`).pipe(
      catchError(error => {
        console.error('Error fetching statistics:', error);
        return throwError(() => error);
      })
    );
  }

  // ============================================
  // POST - Créer
  // ============================================

  /**
   * Créer une nouvelle PFE
   */
  createPFE(pfe: Omit<PFEListing, 'id'>): Observable<PFEListing> {
    return this.http.post<PFEListing>(`${this.API_URL}/pfe/listings`, pfe).pipe(
      tap(newPFE => {
        // Ajouter au cache local
        const currentListings = this.pfeListingsSubject.value;
        this.pfeListingsSubject.next([newPFE, ...currentListings]);
      }),
      catchError(error => {
        console.error('Error creating PFE:', error);
        return throwError(() => error);
      })
    );
  }

  // ============================================
  // PUT - Modifier
  // ============================================

  /**
   * Modifier une PFE existante
   */
  updatePFE(id: string, pfe: Partial<PFEListing>): Observable<PFEListing> {
    return this.http.put<PFEListing>(`${this.API_URL}/pfe/listings/${id}`, pfe).pipe(
      tap(updatedPFE => {
        // Mettre à jour le cache local
        const currentListings = this.pfeListingsSubject.value;
        const updatedListings = currentListings.map(p =>
          p.id === id ? updatedPFE : p
        );
        this.pfeListingsSubject.next(updatedListings);
      }),
      catchError(error => {
        console.error('Error updating PFE:', error);
        return throwError(() => error);
      })
    );
  }

  // ============================================
  // DELETE - Supprimer
  // ============================================

  /**
   * Supprimer une PFE
   */
  deletePFE(id: string): Observable<void> {
    return this.http.delete<void>(`${this.API_URL}/pfe/listings/${id}`).pipe(
      tap(() => {
        // Retirer du cache local
        const currentListings = this.pfeListingsSubject.value;
        const filteredListings = currentListings.filter(p => p.id !== id);
        this.pfeListingsSubject.next(filteredListings);
      }),
      catchError(error => {
        console.error('Error deleting PFE:', error);
        return throwError(() => error);
      })
    );
  }

  // ============================================
  // Méthodes utilitaires
  // ============================================

  /**
   * Rafraîchir les listings depuis le serveur
   */
  refreshListings(): void {
    this.getPFEListings().subscribe();
  }

  /**
   * Obtenir les listings en cache (synchrone)
   */
  getCachedListings(): PFEListing[] {
    return this.pfeListingsSubject.value;
  }
}
