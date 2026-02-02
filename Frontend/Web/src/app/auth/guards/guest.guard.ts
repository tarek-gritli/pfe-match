import { inject } from '@angular/core';
import { Router, type CanActivateFn } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const guestGuard: CanActivateFn = (_route, _state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (!authService.isAuthenticated) {
    return true;
  }

  const authState = authService.currentAuthState;

  if (authState.userType === 'student') {
    if (!authState.profileCompleted) {
      router.navigate(['/create-profile']);
    } else {
      router.navigate(['/explore']);
    }
  } else if (authState.userType === 'enterprise') {
    router.navigate(['/enterprise/dashboard']);
  }

  return false;
};
