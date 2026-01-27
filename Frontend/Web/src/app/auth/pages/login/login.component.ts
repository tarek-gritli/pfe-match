import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent {
  loginForm: FormGroup;
  showPassword = false;
  isLoading = false;
  isGoogleLoading = false;
  errorMessage = '';

  constructor(private fb: FormBuilder, private router: Router) {
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', Validators.required],
      rememberMe: [false]
    });
  }

  async submit() {
    if (this.loginForm.invalid) {
      this.loginForm.markAllAsTouched();
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      // Simulate API call
      await new Promise(res => setTimeout(res, 1500));

      // On success, navigate to dashboard
      this.router.navigate(['/dashboard']);
    } catch (error) {
      this.errorMessage = 'Invalid email or password. Please try again.';
    } finally {
      this.isLoading = false;
    }
  }

  async signInWithGoogle() {
    this.isGoogleLoading = true;
    this.errorMessage = '';

    try {
      // Simulate Google OAuth API call
      await new Promise(res => setTimeout(res, 1500));

      // On success, navigate to dashboard
      this.router.navigate(['/dashboard']);
    } catch (error) {
      this.errorMessage = 'Google sign-in failed. Please try again.';
    } finally {
      this.isGoogleLoading = false;
    }
  }
}
