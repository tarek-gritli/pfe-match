import { Component, OnInit, OnDestroy, HostListener, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import { Subscription } from 'rxjs';
import { AuthService } from '../../../auth/services/auth.service';
import { AuthState, StudentProfile, EnterpriseProfile } from '../../../auth/model/auth.model';
import { API_CONFIG } from '../../../api/api.config';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule, RouterLink],
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

  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.authSubscription = this.authService.authState$.subscribe((state: AuthState) => {
      this.authState = state;
      if (state.isAuthenticated) {
        this.loadProfile();
      }
    });
  }

  ngOnDestroy(): void {
    this.authSubscription?.unsubscribe();
    this.profileSubscription?.unsubscribe();
  }

  private loadProfile(): void {
    if (this.authState?.userType === 'student') {
      this.profileSubscription = this.authService.getStudentProfile().subscribe({
        next: (profile: StudentProfile) => {
          this.userName = `${profile.first_name} ${profile.last_name}`;
          if (profile.profile_picture) {
            this.profilePicture = `${API_CONFIG.BASE_URL}${profile.profile_picture}`;
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
        next: (profile: EnterpriseProfile) => {
          this.userName = profile.company_name;
          if (profile.company_logo) {
            this.profilePicture = `${API_CONFIG.BASE_URL}${profile.company_logo}`;
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
    if (this.authState?.userType === 'student') {
      this.router.navigate(['/profile']);
    } else {
      this.router.navigate(['/enterprise/dashboard']);
    }
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
