import { Component, OnInit, OnDestroy, HostListener, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { Subscription } from 'rxjs';
import { AuthService } from '../../../auth/services/auth.service';
import { AuthState, StudentProfile, EnterpriseProfile } from '../../../auth/model/auth.model';
import { API_CONFIG } from '../../../api/api.config';
import { NotificationService, Notification } from '../../../services/notification.service';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive],
  templateUrl: './navbar.component.html',
  styleUrl: './navbar.component.css'
})
export class NavbarComponent implements OnInit, OnDestroy {
  authState: AuthState | null = null;
  profilePicture: string | null = null;
  userName: string = '';
  isDropdownOpen = signal(false);
  isNotificationDropdownOpen = signal(false);

  private authSubscription?: Subscription;
  private profileSubscription?: Subscription;
  private profileUpdatedSubscription?: Subscription;
  private pollingSubscription?: Subscription;

  constructor(
    private authService: AuthService,
    private router: Router,
    public notificationService: NotificationService
  ) { }

  ngOnInit(): void {
    this.authSubscription = this.authService.authState$.subscribe((state: AuthState) => {
      this.authState = state;
      if (state.isAuthenticated) {
        this.loadProfile();
        // Load notifications when user is authenticated
        this.notificationService.getNotifications().subscribe();
        this.notificationService.getUnreadCount().subscribe();
        // Start polling for new notifications every 30 seconds
        this.pollingSubscription = this.notificationService.startPolling(30000).subscribe();
      }
    });

    // Subscribe to profile updates to refresh navbar when profile picture changes
    this.profileUpdatedSubscription = this.authService.profileUpdated$.subscribe(() => {
      this.loadProfile();
    });
  }

  ngOnDestroy(): void {
    this.authSubscription?.unsubscribe();
    this.profileSubscription?.unsubscribe();
    this.profileUpdatedSubscription?.unsubscribe();
    this.pollingSubscription?.unsubscribe();
  }

  private loadProfile(): void {
    if (this.authState?.userType === 'student') {
      this.profileSubscription = this.authService.getStudentProfile().subscribe({
        next: (profile: StudentProfile) => {
          this.userName = `${profile.firstName} ${profile.lastName}`;
          if (profile.profileImage) {
            // Handle both absolute paths and relative paths, normalize backslashes
            const imagePath = profile.profileImage.replace(/\\/g, '/');
            this.profilePicture = imagePath.startsWith('/') 
              ? `${API_CONFIG.BASE_URL}${imagePath}`
              : `${API_CONFIG.BASE_URL}/${imagePath}`;
          }
        },
        error: () => {
          // Profile might not exist yet, use default
          this.userName = '';
          this.profilePicture = null;
        }
      });
    } else if (this.authState?.userType === 'enterprise') {
      this.profileSubscription = this.authService.getEnterpriseProfile().subscribe({
        next: (profile: any) => {
          this.userName = profile.name || profile.company_name;
          const logo = profile.logo || profile.company_logo;
          if (logo) {
            // Handle both absolute paths and relative paths, normalize backslashes
            const logoPath = logo.replace(/\\/g, '/');
            this.profilePicture = logoPath.startsWith('/') 
              ? `${API_CONFIG.BASE_URL}${logoPath}`
              : `${API_CONFIG.BASE_URL}/${logoPath}`;
          }
        },
        error: () => {
          this.userName = '';
          this.profilePicture = null;
        }
      });
    }
  }

  toggleDropdown(): void {
    this.isDropdownOpen.update((value: boolean) => !value);
    this.isNotificationDropdownOpen.set(false);
  }

  closeDropdown(): void {
    this.isDropdownOpen.set(false);
  }

  toggleNotificationDropdown(): void {
    this.isNotificationDropdownOpen.update((value: boolean) => !value);
    this.isDropdownOpen.set(false);
    // Load fresh notifications when opening
    if (this.isNotificationDropdownOpen()) {
      this.notificationService.getNotifications().subscribe();
    }
  }

  closeNotificationDropdown(): void {
    this.isNotificationDropdownOpen.set(false);
  }

  onNotificationClick(notification: Notification): void {
    // Mark as read
    this.notificationService.markAsRead(notification.id).subscribe();
    
    // Navigate based on notification type
    if (notification.pfe_listing_id) {
      this.router.navigate(['/companies/applicants'], { 
        queryParams: { pfeId: notification.pfe_listing_id } 
      });
    }
    this.closeNotificationDropdown();
  }

  markAllNotificationsAsRead(): void {
    this.notificationService.markAllAsRead().subscribe();
  }

  @HostListener('document:click', ['$event'])
  onDocumentClick(event: MouseEvent): void {
    const target = event.target as HTMLElement;
    if (!target.closest('.profile-dropdown-container')) {
      this.closeDropdown();
    }
    if (!target.closest('.notification-dropdown-container')) {
      this.closeNotificationDropdown();
    }
  }

  navigateToProfile(): void {
    this.closeDropdown();
    this.router.navigate(['/profile']);
  }

  logout(): void {
    this.closeDropdown();
    this.authService.logout();
  }

  getInitials(): string {
    if (this.userName) {
      const parts = this.userName.split(' ');
      if (parts.length >= 2) {
        return (parts[0][0] + parts[1][0]).toUpperCase();
      }
      return this.userName.substring(0, 2).toUpperCase();
    }
    return 'U';
  }
}
