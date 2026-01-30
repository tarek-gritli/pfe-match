import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
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

type AccountType = 'student' | 'enterprise' | null;

@Component({
  selector: 'app-signup',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
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
  showPassword = false;
  showConfirmPassword = false;

  // Student fields
  studentName = '';
  studentEmail = '';
  university = '';
  studentPassword = '';
  studentConfirmPassword = '';

  // Enterprise fields
  companyName = '';
  businessEmail = '';
  industry = '';
  enterprisePassword = '';
  enterpriseConfirmPassword = '';

  constructor(private router: Router) {}

  // Validation helpers
  isValidEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  get studentPasswordsMatch(): boolean {
    return this.studentPassword === this.studentConfirmPassword && this.studentPassword.length > 0;
  }

  get enterprisePasswordsMatch(): boolean {
    return this.enterprisePassword === this.enterpriseConfirmPassword && this.enterprisePassword.length > 0;
  }

  get isStudentFormValid(): boolean {
    return (
      this.studentName.trim() !== '' &&
      this.isValidEmail(this.studentEmail) &&
      this.university.trim() !== '' &&
      this.studentPassword.length >= 6 &&
      this.studentPasswordsMatch
    );
  }

  get isEnterpriseFormValid(): boolean {
    return (
      this.companyName.trim() !== '' &&
      this.isValidEmail(this.businessEmail) &&
      this.industry.trim() !== '' &&
      this.enterprisePassword.length >= 6 &&
      this.enterprisePasswordsMatch
    );
  }

  setAccountType(type: AccountType): void {
    this.accountType = type;
  }

  handleStudentSubmit(event: Event): void {
    event.preventDefault();
    this.router.navigate(['/create-profile']);
  }

  handleEnterpriseSubmit(event: Event): void {
    event.preventDefault();
    this.router.navigate(['/']);
  }

  handleGoogleSignUp(): void {
    this.router.navigate(['/create-profile']);
  }

  togglePasswordVisibility(): void {
    this.showPassword = !this.showPassword;
  }

  toggleConfirmPasswordVisibility(): void {
    this.showConfirmPassword = !this.showConfirmPassword;
  }

  getEmailInputClass(email: string): string {
    return email && !this.isValidEmail(email) ? 'input-error' : '';
  }

  getPasswordInputClass(confirmPassword: string, passwordsMatch: boolean): string {
    return confirmPassword && !passwordsMatch ? 'input-error' : '';
  }
}