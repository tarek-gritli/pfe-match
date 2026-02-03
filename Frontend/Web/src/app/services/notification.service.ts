import { Injectable, inject, signal, computed } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, interval, switchMap, tap, catchError, of } from 'rxjs';

export interface Notification {
  id: number;
  title: string;
  message: string;
  type: string;
  is_read: boolean;
  pfe_listing_id: number | null;
  application_id: number | null;
  created_at: string;
}

export interface UnreadCountResponse {
  count: number;
}

@Injectable({
  providedIn: 'root'
})
export class NotificationService {
  private http = inject(HttpClient);
  private readonly API_URL = 'http://localhost:8000/api/notifications';
  private readonly TOKEN_KEY = 'pfe_match_token';

  // Signals for reactive state
  private notificationsSignal = signal<Notification[]>([]);
  private unreadCountSignal = signal<number>(0);
  private loadingSignal = signal<boolean>(false);

  // Public computed values
  notifications = this.notificationsSignal.asReadonly();
  unreadCount = this.unreadCountSignal.asReadonly();
  loading = this.loadingSignal.asReadonly();
  
  hasUnread = computed(() => this.unreadCountSignal() > 0);

  private getAuthHeaders(): HttpHeaders {
    const token = localStorage.getItem(this.TOKEN_KEY);
    let headers = new HttpHeaders({
      'Content-Type': 'application/json'
    });
    if (token) {
      headers = headers.set('Authorization', `Bearer ${token}`);
    }
    return headers;
  }

  /**
   * Fetch all notifications for the current user
   */
  getNotifications(unreadOnly: boolean = false): Observable<Notification[]> {
    this.loadingSignal.set(true);
    const url = unreadOnly ? `${this.API_URL}?unread_only=true` : this.API_URL;
    
    return this.http.get<Notification[]>(url, { headers: this.getAuthHeaders() }).pipe(
      tap(notifications => {
        this.notificationsSignal.set(notifications);
        this.loadingSignal.set(false);
      }),
      catchError(error => {
        console.error('Error fetching notifications:', error);
        this.loadingSignal.set(false);
        return of([]);
      })
    );
  }

  /**
   * Get unread notification count
   */
  getUnreadCount(): Observable<UnreadCountResponse> {
    return this.http.get<UnreadCountResponse>(`${this.API_URL}/unread-count`, { headers: this.getAuthHeaders() }).pipe(
      tap(response => {
        this.unreadCountSignal.set(response.count);
      }),
      catchError(error => {
        console.error('Error fetching unread count:', error);
        return of({ count: 0 });
      })
    );
  }

  /**
   * Mark a specific notification as read
   */
  markAsRead(notificationId: number): Observable<any> {
    return this.http.post(`${this.API_URL}/${notificationId}/read`, {}, { headers: this.getAuthHeaders() }).pipe(
      tap(() => {
        // Update local state
        const notifications = this.notificationsSignal();
        const updated = notifications.map(n => 
          n.id === notificationId ? { ...n, is_read: true } : n
        );
        this.notificationsSignal.set(updated);
        
        // Decrease unread count
        const currentCount = this.unreadCountSignal();
        if (currentCount > 0) {
          this.unreadCountSignal.set(currentCount - 1);
        }
      }),
      catchError(error => {
        console.error('Error marking notification as read:', error);
        return of(null);
      })
    );
  }

  /**
   * Mark all notifications as read
   */
  markAllAsRead(): Observable<any> {
    return this.http.post(`${this.API_URL}/read-all`, {}, { headers: this.getAuthHeaders() }).pipe(
      tap(() => {
        // Update local state
        const notifications = this.notificationsSignal();
        const updated = notifications.map(n => ({ ...n, is_read: true }));
        this.notificationsSignal.set(updated);
        this.unreadCountSignal.set(0);
      }),
      catchError(error => {
        console.error('Error marking all notifications as read:', error);
        return of(null);
      })
    );
  }

  /**
   * Start polling for new notifications
   */
  startPolling(intervalMs: number = 30000): Observable<UnreadCountResponse> {
    return interval(intervalMs).pipe(
      switchMap(() => this.getUnreadCount())
    );
  }

  /**
   * Refresh notifications (manual refresh)
   */
  refresh(): void {
    this.getNotifications().subscribe();
    this.getUnreadCount().subscribe();
  }

  /**
   * Get time ago string for notification
   */
  getTimeAgo(dateString: string): string {
    const date = new Date(dateString);
    const now = new Date();
    const seconds = Math.floor((now.getTime() - date.getTime()) / 1000);

    if (seconds < 60) return 'Just now';
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
    if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`;
    if (seconds < 604800) return `${Math.floor(seconds / 86400)}d ago`;
    
    return date.toLocaleDateString();
  }
}
