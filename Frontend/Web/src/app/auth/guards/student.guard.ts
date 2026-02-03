import { inject } from '@angular/core';
import { Router, type CanActivateFn } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const studentGuard: CanActivateFn = (_route, _state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  // Check if user is authenticated and is a student
  if (authService.isAuthenticated && authService.getUserType() === 'student') {
    return true;
  }

  // If authenticated but not student, redirect to appropriate page
  if (authService.isAuthenticated) {
    router.navigate(['/companies/overview-pfe']);
  } else {
    router.navigate(['/login']);
  }
  
  return false;
};
