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

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [
    FormsModule,
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
  showPassword = false;
  email = '';
  password = '';
  rememberMe = false;

  constructor(private router: Router) {}

  get isFormValid(): boolean {
    return this.email.trim() !== '' && this.password.trim() !== '';
  }

  handleSubmit(event: Event): void {
    event.preventDefault();
    // For now, just navigate to home
    this.router.navigate(['/']);
  }

  handleGoogleSignIn(): void {
    // Placeholder for Google sign-in
    this.router.navigate(['/']);
  }

  togglePasswordVisibility(): void {
    this.showPassword = !this.showPassword;
  }
}