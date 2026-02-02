import { Component, OnInit, OnDestroy } from '@angular/core';
import { Router, RouterOutlet, NavigationEnd, Event } from '@angular/router';
import { CommonModule } from '@angular/common';
import { Subscription, filter } from 'rxjs';
import { NavbarComponent } from './components/Common/navbar/navbar.component';
import { AuthService } from './auth/services/auth.service';
import { AuthState } from './auth/model/auth.model';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, CommonModule, NavbarComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit, OnDestroy {
  title = 'Web';
  showNavbar = false;
  
  private routerSubscription?: Subscription;
  private authSubscription?: Subscription;
  
  // Routes where navbar should be hidden
  private readonly hiddenNavbarRoutes = ['/login', '/register'];
  
  constructor(
    private router: Router,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    // Subscribe to router events to show/hide navbar
    this.routerSubscription = this.router.events
      .pipe(filter((event: Event): event is NavigationEnd => event instanceof NavigationEnd))
      .subscribe((event: NavigationEnd) => {
        this.updateNavbarVisibility(event.urlAfterRedirects);
      });

    // Also check auth state
    this.authSubscription = this.authService.authState$.subscribe((state: AuthState) => {
      // Only show navbar if authenticated and not on login/register pages
      const currentUrl = this.router.url;
      this.updateNavbarVisibility(currentUrl, state.isAuthenticated);
    });
  }

  ngOnDestroy(): void {
    this.routerSubscription?.unsubscribe();
    this.authSubscription?.unsubscribe();
  }

  private updateNavbarVisibility(url: string, isAuthenticated?: boolean): void {
    const isAuth = isAuthenticated ?? this.authService.isAuthenticated;
    const isHiddenRoute = this.hiddenNavbarRoutes.some(route => url.startsWith(route));
    this.showNavbar = isAuth && !isHiddenRoute;
  }
}
