import { Component, OnInit, OnDestroy, HostListener, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { Subscription } from 'rxjs';
import { AuthService } from '../../../auth/services/auth.service';
import { AuthState, StudentProfile, EnterpriseProfile } from '../../../auth/model/auth.model';
import { API_CONFIG } from '../../../api/api.config';

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
  notificationCount = signal(3); // Can be made dynamic later
  isDropdownOpen = signal(false);

  private authSubscription?: Subscription;
  private profileSubscription?: Subscription;
  private profileUpdatedSubscription?: Subscription;

  constructor(
    private authService: AuthService,
    private router: Router
  ) { }

  ngOnInit(): void {
    this.authSubscription = this.authService.authState$.subscribe((state: AuthState) => {
      this.authState = state;
      if (state.isAuthenticated) {
        this.loadProfile();
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
  }

  closeDropdown(): void {
    this.isDropdownOpen.set(false);
  }

  @HostListener('document:click', ['$event'])
  onDocumentClick(event: MouseEvent): void {
    const target = event.target as HTMLElement;
    if (!target.closest('.profile-dropdown-container')) {
      this.closeDropdown();
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
