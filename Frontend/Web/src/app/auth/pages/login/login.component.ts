import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { ButtonComponent } from '../../../components/Common/button/button.component';
import { InputComponent } from '../../../components/Common/input/input.component';
import { LabelComponent } from '../../../components/Common/label/label.component';
import { CheckboxComponent } from '../../../components/Common/checkbox/checkbox.component';
import { CardComponent } from '../../../components/Common/card/card.component';
import { CardHeaderComponent } from '../../../components/Common/card/card.component';
import { CardTitleComponent } from '../../../components/Common/card/card.component';
import { CardDescriptionComponent } from '../../../components/Common/card/card.component';
import { CardContentComponent } from '../../../components/Common/card/card.component';
import { CardFooterComponent } from '../../../components/Common/card/card.component';
import { SeparatorComponent } from '../../../components/Common/separator/separator.component';

// Import new Common components
import { AuthCardComponent } from '../../../components/Common/auth-card/auth-card.component';
import { FormFieldComponent } from '../../../components/Common/form-field/form-field.component';
import { PasswordInputComponent } from '../../../components/Common/password-input/password-input.component';
import { ErrorAlertComponent } from '../../../components/Common/error-alert/error-alert.component';
import { SuccessAlertComponent } from '../../../components/Common/success-alert/success-alert.component';
import { LoadingButtonComponent } from '../../../components/Common/loading-button/loading-button.component';
import { DividerComponent } from '../../../components/Common/divider/divider.component';
import { GoogleButtonComponent } from '../../../components/Common/google-button/google-button.component';

// Import existing Common component
import { InputComponent } from '../../../components/Common/input/input.component';

// Import auth service
import { AuthService } from '../../services/auth.service';
import { LoginRequest } from '../../model/auth.model';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    RouterModule,
    // New Common components
    AuthCardComponent,
    FormFieldComponent,
    PasswordInputComponent,
    ErrorAlertComponent,
    SuccessAlertComponent,
    LoadingButtonComponent,
    DividerComponent,
    GoogleButtonComponent,
  ],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent {
  loginForm: FormGroup;
  isLoading = false;
  isGoogleLoading = false;
  errorMessage = '';
  successMessage = '';

  constructor(
    private fb: FormBuilder,
    private router: Router,
    private authService: AuthService
  ) {
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', Validators.required],
      rememberMe: [false]
    });
  }

  /**
   * Check if email field has validation errors and has been touched
   */
  get emailHasError(): boolean {
    const email = this.loginForm.get('email');
    return !!(email?.touched && email?.invalid);
  }

  /**
   * Check if password field has validation errors and has been touched
   */
  get passwordHasError(): boolean {
    const password = this.loginForm.get('password');
    return !!(password?.touched && password?.invalid);
  }

  /**
   * Handle form submission
   */
  submit(): void {
    if (this.loginForm.invalid) {
      this.loginForm.markAllAsTouched();
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';
    this.successMessage = '';

    const loginData: LoginRequest = {
      email: this.loginForm.value.email,
      password: this.loginForm.value.password
    };

    this.authService.login(loginData).subscribe({
      next: (response) => {
        this.isLoading = false;
        this.successMessage = 'Login successful! Redirecting...';

        // Navigate based on profile completion status and user type after short delay
        setTimeout(() => {
          if (!response.profile_completed) {
            if (response.user_type === 'student') {
              this.router.navigate(['/create-profile']);
            } else {
              this.router.navigate(['/enterprise/create-profile']);
            }
          } else {
            // Navigate to dashboard or profile
            if (response.user_type === 'student') {
              this.router.navigate(['/profile']);
            } else {
              this.router.navigate(['/enterprise/dashboard']);
            }
          }
        }, 1000);
      },
      error: (error) => {
        this.isLoading = false;
        this.errorMessage = error.message || 'Invalid email or password. Please try again.';
      }
    });
  }

  /**
   * Handle Google OAuth sign-in
   */
  async signInWithGoogle(): Promise<void> {
    this.isGoogleLoading = true;
    this.errorMessage = '';

    try {
      // TODO: Implement Google OAuth
      await new Promise(res => setTimeout(res, 1500));
      this.router.navigate(['/dashboard']);
    } catch (error) {
      this.errorMessage = 'Google sign-in failed. Please try again.';
    } finally {
      this.isGoogleLoading = false;
    }
  }
}