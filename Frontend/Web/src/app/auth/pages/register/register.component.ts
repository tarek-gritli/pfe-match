import { Component } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ButtonComponent } from '../../../components/Common/button/button.component';
import { InputComponent } from '../../../components/Common/input/input.component';
import { LabelComponent } from '../../../components/Common/label/label.component';
import { CardComponent } from '../../../components/Common/card/card.component';
import { CardHeaderComponent } from '../../../components/Common/card/card.component';
import { CardTitleComponent } from '../../../components/Common/card/card.component';
import { CardDescriptionComponent } from '../../../components/Common/card/card.component';
import { CardContentComponent } from '../../../components/Common/card/card.component';
import { CardFooterComponent } from '../../../components/Common/card/card.component';
import { SeparatorComponent } from '../../../components/Common/separator/separator.component';
import { AuthService } from '../../services/auth.service';
import { StudentRegisterRequest, EnterpriseRegisterRequest } from '../../model/auth.model';

type AccountType = 'student' | 'enterprise' | null;

@Component({
  selector: 'app-signup',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    RouterLink,
    ButtonComponent,
    InputComponent,
    LabelComponent,
    CardComponent,
    CardHeaderComponent,
    CardTitleComponent,
    CardDescriptionComponent,
    CardContentComponent,
    CardFooterComponent,
    SeparatorComponent
  ],
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css']
})
export class RegisterComponent {
  accountType: AccountType = null;
  isLoading = false;
  isGoogleLoading = false;
  errorMessage = '';
  successMessage = '';

  studentForm: FormGroup;
  enterpriseForm: FormGroup;

  // Password visibility toggles
  showPassword = false;
  showConfirmPassword = false;

  passwordRequirements = [
    { label: 'At least 8 characters',     check: (p: string) => p.length >= 8 },
    { label: 'Contains uppercase letter', check: (p: string) => /[A-Z]/.test(p) },
    { label: 'Contains lowercase letter', check: (p: string) => /[a-z]/.test(p) },
    { label: 'Contains a number',         check: (p: string) => /[0-9]/.test(p) },
  ];

  constructor(
    private fb: FormBuilder,
    private router: Router,
    private authService: AuthService
  ) {
    this.studentForm = this.fb.group({
      firstName:        ['', [Validators.required, Validators.minLength(2), Validators.maxLength(100)]],
      lastName:         ['', [Validators.required, Validators.minLength(2), Validators.maxLength(100)]],
      email:            ['', [Validators.required, Validators.email]],
      password:         ['', [Validators.required, Validators.minLength(8)]],
      confirmPassword:  ['', Validators.required],
    });

    this.enterpriseForm = this.fb.group({
      companyName:      ['', [Validators.required, Validators.minLength(2), Validators.maxLength(200)]],
      email:            ['', [Validators.required, Validators.email]],
      industry:         ['', [Validators.required, Validators.minLength(2)]],
      password:         ['', [Validators.required, Validators.minLength(8)]],
      confirmPassword:  ['', Validators.required],
    });
  }

  // ─── Account-type selection ───────────────────────────────────────

  setAccountType(type: AccountType): void {
    this.accountType = type;
    this.errorMessage = '';
    this.successMessage = '';
  }

  // ─── Password helpers ─────────────────────────────────────────────

  /**
   * Returns the current password value from whichever form is active.
   */
  get currentPassword(): string {
    const form = this.activeForm;
    return form?.value.password ?? '';
  }

  /**
   * True when every item in passwordRequirements passes.
   */
  passwordMeetsRequirements(): boolean {
    return this.passwordRequirements.every(req => req.check(this.currentPassword));
  }

  /**
   * True when password and confirmPassword match in the active form.
   */
  passwordsMatch(): boolean {
    const form = this.activeForm;
    return form?.value.password === form?.value.confirmPassword;
  }

  togglePasswordVisibility(): void {
    this.showPassword = !this.showPassword;
  }

  toggleConfirmPasswordVisibility(): void {
    this.showConfirmPassword = !this.showConfirmPassword;
  }

  // ─── Input-class helpers (for error styling on individual fields) ─

  getEmailInputClass(): string {
    const form = this.activeForm;
    const emailControl = form?.get('email');
    return emailControl?.touched && emailControl?.invalid ? 'input-error' : '';
  }

  getConfirmPasswordInputClass(): string {
    const form = this.activeForm;
    const confirmControl = form?.get('confirmPassword');
    // Show error once the user has typed something in confirmPassword and it doesn't match
    return confirmControl?.touched && !this.passwordsMatch() ? 'input-error' : '';
  }

  // ─── Shared convenience ───────────────────────────────────────────

  /**
   * Whichever form corresponds to the current accountType.
   */
  private get activeForm(): FormGroup | null {
    if (this.accountType === 'student')    return this.studentForm;
    if (this.accountType === 'enterprise') return this.enterpriseForm;
    return null;
  }

  // ─── Submission ───────────────────────────────────────────────────

  handleStudentSubmit(event: Event): void {
    event.preventDefault();
    this.errorMessage = '';
    this.successMessage = '';

    if (this.studentForm.invalid) {
      this.studentForm.markAllAsTouched();
      this.errorMessage = 'Please fill in all required fields correctly.';
      return;
    }

    if (!this.passwordsMatch()) {
      this.errorMessage = 'Passwords do not match.';
      return;
    }

    if (!this.passwordMeetsRequirements()) {
      this.errorMessage = 'Password does not meet the requirements above.';
      return;
    }

    this.isLoading = true;

    const studentData: StudentRegisterRequest = {
      email:      this.studentForm.value.email,
      password:   this.studentForm.value.password,
      first_name: this.studentForm.value.firstName,
      last_name:  this.studentForm.value.lastName   // V1 only had a single "name" field; extend the form if you need a last name
    };

    this.authService.registerStudent(studentData).subscribe({
      next: () => {
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
  }

  handleEnterpriseSubmit(event: Event): void {
    event.preventDefault();
    this.errorMessage = '';
    this.successMessage = '';

    if (this.enterpriseForm.invalid) {
      this.enterpriseForm.markAllAsTouched();
      this.errorMessage = 'Please fill in all required fields correctly.';
      return;
    }

    if (!this.passwordsMatch()) {
      this.errorMessage = 'Passwords do not match.';
      return;
    }

    if (!this.passwordMeetsRequirements()) {
      this.errorMessage = 'Password does not meet the requirements above.';
      return;
    }

    this.isLoading = true;

    const enterpriseData: EnterpriseRegisterRequest = {
      email:        this.enterpriseForm.value.email,
      password:     this.enterpriseForm.value.password,
      company_name: this.enterpriseForm.value.companyName,
      industry:     this.enterpriseForm.value.industry
    };

    this.authService.registerEnterprise(enterpriseData).subscribe({
      next: () => {
        this.isLoading = false;
        this.successMessage = 'Company account created successfully! Redirecting...';
        setTimeout(() => {
          this.router.navigate(['/create-profile']);
        }, 1500);
      },
      error: (error) => {
        this.isLoading = false;
        this.errorMessage = error.message || 'Registration failed. Please try again.';
      }
    });
  }

  // ─── Google OAuth ─────────────────────────────────────────────────

  async handleGoogleSignUp(): Promise<void> {
    this.isGoogleLoading = true;
    this.errorMessage = '';

    try {
      // TODO: wire up real Google OAuth via AuthService
      await new Promise(res => setTimeout(res, 1500));
      this.router.navigate(['/create-profile']);
    } catch {
      this.errorMessage = 'Google sign-up failed. Please try again.';
    } finally {
      this.isGoogleLoading = false;
    }
  }
}