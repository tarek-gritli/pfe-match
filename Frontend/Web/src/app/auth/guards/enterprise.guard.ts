import { inject } from '@angular/core';
import { Router, type CanActivateFn } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const enterpriseGuard: CanActivateFn = (_route, _state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  // Check if user is authenticated and is an enterprise
  if (authService.isAuthenticated && authService.getUserType() === 'enterprise') {
    return true;
  }

  // If authenticated but not enterprise, redirect to appropriate page
  if (authService.isAuthenticated) {
    router.navigate(['/explore']);
  } else {
    router.navigate(['/login']);
  }
  
  return false;
};
