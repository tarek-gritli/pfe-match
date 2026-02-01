import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { AuthCardComponent } from '../../../components/Common/auth-card/auth-card.component';
import { FormFieldComponent } from '../../../components/Common/form-field/form-field.component';
import { PasswordInputComponent } from '../../../components/Common/password-input/password-input.component';
import { ErrorAlertComponent } from '../../../components/Common/error-alert/error-alert.component';
import { SuccessAlertComponent } from '../../../components/Common/success-alert/success-alert.component';
import { LoadingButtonComponent } from '../../../components/Common/loading-button/loading-button.component';
import { DividerComponent } from '../../../components/Common/divider/divider.component';
import { GoogleButtonComponent } from '../../../components/Common/google-button/google-button.component';
import { AuthService } from '../../services/auth.service';
import { StudentRegisterRequest, EnterpriseRegisterRequest } from '../../model/auth.model';

@Component({
  selector: 'app-signup',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    RouterModule,
    AuthCardComponent,
    FormFieldComponent,
    PasswordInputComponent,
    ErrorAlertComponent,
    SuccessAlertComponent,
    LoadingButtonComponent,
    DividerComponent,
    GoogleButtonComponent
  ],
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css']
})
export class RegisterComponent {
  activeTab: 'student' | 'enterprise' | null = null;
  tabSelected = false;
  isLoading = false;
  successMessage = '';
  isGoogleLoading = false;
  errorMessage = '';
  studentForm: FormGroup;
  enterpriseForm: FormGroup;

  passwordRequirements = [
    { label: 'At least 8 characters', check: (p: string) => p.length >= 8 },
    { label: 'Contains uppercase letter', check: (p: string) => /[A-Z]/.test(p) },
    { label: 'Contains lowercase letter', check: (p: string) => /[a-z]/.test(p) },
    { label: 'Contains a number', check: (p: string) => /[0-9]/.test(p) },
  ];

  constructor(
    private fb: FormBuilder,
    private router: Router,
    private authService: AuthService
  ) {
    // Initialize student form with validation
    this.studentForm = this.fb.group({
      firstName: ['', [Validators.required, Validators.minLength(2), Validators.maxLength(100)]],
      lastName: ['', [Validators.required, Validators.minLength(2), Validators.maxLength(100)]],
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(8)]],
      confirmPassword: ['', Validators.required],
    });

    // Initialize enterprise form with validation
    this.enterpriseForm = this.fb.group({
      companyName: ['', [Validators.required, Validators.minLength(2), Validators.maxLength(200)]],
      email: ['', [Validators.required, Validators.email]],
      industry: ['', [Validators.required, Validators.minLength(2)]],
      password: ['', [Validators.required, Validators.minLength(8)]],
      confirmPassword: ['', Validators.required],
    });
  }

  get studentPasswordsMatch(): boolean {
    return this.studentForm.value.password === this.studentForm.value.confirmPassword && this.studentForm.value.password.length > 0;
  }

  get currentPassword(): string {
    if (!this.activeTab) return '';
    const form = this.activeTab === 'student' ? this.studentForm : this.enterpriseForm;
    return form.value.password || '';
  }

  /**
   * Switch between student and enterprise registration tabs
   */
  switchTab(tab: 'student' | 'enterprise'): void {
    this.activeTab = tab;
    this.tabSelected = true;
    this.errorMessage = '';
  }

  /**
   * Check if passwords match in the given form
   */
  passwordsMatch(form: FormGroup): boolean {
    return form.value.password === form.value.confirmPassword;
  }

  /**
   * Check if password meets all requirements
   */
  passwordMeetsRequirements(): boolean {
    return this.passwordRequirements.every(req => req.check(this.currentPassword));
  }

  /**
   * Handle form submission
   */
  submit(): void {
    const form = this.activeTab === 'student' ? this.studentForm : this.enterpriseForm;

    if (form.invalid) {
      form.markAllAsTouched();
      this.errorMessage = 'Please fill in all required fields correctly.';
      return;
    }

    if (!this.passwordsMatch(form)) {
      this.errorMessage = 'Passwords do not match';
      return;
    }

    if (!this.passwordMeetsRequirements()) {
      this.errorMessage = 'Password does not meet requirements';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';
    this.successMessage = '';

    if (this.activeTab === 'student') {
      const studentData: StudentRegisterRequest = {
        email: this.studentForm.value.email,
        password: this.studentForm.value.password,
        first_name: this.studentForm.value.firstName,
        last_name: this.studentForm.value.lastName
      };
      this.authService.registerStudent(studentData).subscribe({
        next: (response) => {
          console.log('Registration success:', response);
          this.isLoading = false;
          this.successMessage = 'Account created successfully! Redirecting to profile setup...';
          setTimeout(() => {
            this.router.navigate(['/create-profile']);
          }, 2000);
        },
        error: (error) => {
          this.isLoading = false;
          this.errorMessage = error.message || 'Registration failed. Please try again.';
        }
      });
    } else {
      const enterpriseData: EnterpriseRegisterRequest = {
        email: this.enterpriseForm.value.email,
        password: this.enterpriseForm.value.password,
        company_name: this.enterpriseForm.value.companyName,
        industry: this.enterpriseForm.value.industry
      };

      this.authService.registerEnterprise(enterpriseData).subscribe({
        next: (response) => {
          this.isLoading = false;
          this.successMessage = 'Company account created successfully! Redirecting to profile setup...';
          setTimeout(() => {
            this.router.navigate(['/enterprise/create-profile']);
          }, 1500);
        },
        error: (error) => {
          console.error('Registration error:', error);
          this.isLoading = false;
          this.errorMessage = error.message || 'Registration failed. Please try again.';
        }
      });
    }
  }

  /**
   * Handle Google OAuth sign-up
   */
  async signUpWithGoogle(): Promise<void> {
    this.isGoogleLoading = true;
    this.errorMessage = '';

    try {
      // TODO: Implement Google OAuth
      await new Promise(res => setTimeout(res, 1500));
      this.router.navigate(['/dashboard']);
    } catch (error) {
      this.errorMessage = 'Google sign-up failed. Please try again.';
    } finally {
      this.isGoogleLoading = false;
    }
  }
}