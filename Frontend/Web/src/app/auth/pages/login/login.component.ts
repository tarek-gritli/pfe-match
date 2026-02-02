import { Component, inject } from '@angular/core';
import { Router, RouterLink, ActivatedRoute } from '@angular/router';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
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
import { AuthService } from '../../services/auth.service';
import { LoginRequest } from '../../model/auth.model';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    RouterLink,
    ButtonComponent,
    InputComponent,
    LabelComponent,
    CheckboxComponent,
    CardComponent,
    CardHeaderComponent,
    CardTitleComponent,
    CardDescriptionComponent,
    CardContentComponent,
    CardFooterComponent,
    SeparatorComponent
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
  showPassword = false;
  private returnUrl: string = '';

  private authService = inject(AuthService);

  constructor(
    private fb: FormBuilder,
    private router: Router,
    private route: ActivatedRoute
  ) {
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', Validators.required],
      rememberMe: [false]
    });

    this.returnUrl = this.route.snapshot.queryParams['returnUrl'] || '';
  }

  /**
   * Toggles password field visibility
   */
  togglePasswordVisibility(): void {
    this.showPassword = !this.showPassword;
  }

  /**
   * Handles form submission via the AuthService.
   * Navigates based on profile completion status and user type.
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

        setTimeout(() => {
          if (this.returnUrl) {
            this.router.navigateByUrl(this.returnUrl);
          } else if (!response.profile_completed) {
            this.router.navigate([
              response.user_type === 'student'
                ? '/create-profile'
                : '/create-profile'
            ]);
          } else {
            this.router.navigate([
              response.user_type === 'student'
                ? '/explore'
                : '/companies/overview-pfe'
            ]);
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
   * Handles Google OAuth sign-in
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