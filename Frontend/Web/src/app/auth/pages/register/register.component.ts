import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule],
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css']
})
export class RegisterComponent {

  activeTab: 'student' | 'enterprise' = 'student';
  showPassword = false;
  showConfirmPassword = false;
  isLoading = false;
  isGoogleLoading = false;

  studentForm: FormGroup;
  enterpriseForm: FormGroup;

  passwordRequirements = [
    { label: 'At least 8 characters', check: (p: string) => p.length >= 8 },
    { label: 'Contains uppercase letter', check: (p: string) => /[A-Z]/.test(p) },
    { label: 'Contains lowercase letter', check: (p: string) => /[a-z]/.test(p) },
    { label: 'Contains a number', check: (p: string) => /[0-9]/.test(p) },
  ];

  constructor(private fb: FormBuilder, private router: Router) {
    this.studentForm = this.fb.group({
      fullName: ['', [Validators.required, Validators.maxLength(100)]],
      email: ['', [Validators.required, Validators.email]],
      university: ['', Validators.required],
      password: ['', Validators.required],
      confirmPassword: ['', Validators.required],
    });

    this.enterpriseForm = this.fb.group({
      companyName: ['', [Validators.required, Validators.maxLength(100)]],
      email: ['', [Validators.required, Validators.email]],
      industry: ['', Validators.required],
      password: ['', Validators.required],
      confirmPassword: ['', Validators.required],
    });
  }

  get currentPassword(): string {
    const form = this.activeTab === 'student' ? this.studentForm : this.enterpriseForm;
    return form.get('password')?.value || '';
  }

  switchTab(tab: 'student' | 'enterprise') {
    this.activeTab = tab;
  }

  passwordsMatch(form: FormGroup): boolean {
    return form.value.password === form.value.confirmPassword;
  }

  async submit() {
    const form = this.activeTab === 'student' ? this.studentForm : this.enterpriseForm;

    if (form.invalid || !this.passwordsMatch(form)) {
      form.markAllAsTouched();
      return;
    }

    this.isLoading = true;
    await new Promise(res => setTimeout(res, 1500));
    this.isLoading = false;

    this.router.navigate(['/dashboard']);
  }

  async signUpWithGoogle() {
    this.isGoogleLoading = true;

    try {
      // Simulate Google OAuth API call
      await new Promise(res => setTimeout(res, 1500));

      // On success, navigate to dashboard
      this.router.navigate(['/dashboard']);
    } catch (error) {
      console.error('Google sign-up failed:', error);
    } finally {
      this.isGoogleLoading = false;
    }
  }
}
