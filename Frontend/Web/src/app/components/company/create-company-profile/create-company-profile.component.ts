import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { CardComponent, CardContentComponent, CardDescriptionComponent, CardHeaderComponent, CardTitleComponent } from '../../Common/card/card.component';
import { ButtonComponent } from '../../Common/button/button.component';
import { InputComponent } from '../../Common/input/input.component';
import { TextareaComponent } from '../../Common/textarea/textarea.component';
import { LabelComponent } from '../../Common/label/label.component';
import { BadgeComponent } from '../../Common/badge/badge.component';
import { ProgressComponent } from '../../Common/progress/progress.component';

interface CompanyCreateFormData {
  logo: string;
  location: string;
  size: string;
  foundedYear: number | null;
  description: string;
  website: string;
  linkedinUrl: string;
  contactEmail: string;
  technologies: string[];
}

interface Step {
  id: number;
  title: string;
  icon: string;
}

@Component({
  selector: 'app-create-company-profile',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    CardComponent,
    CardContentComponent,
    CardDescriptionComponent,
    CardHeaderComponent,
    CardTitleComponent,
    ButtonComponent,
    InputComponent,
    TextareaComponent,
    LabelComponent,
    BadgeComponent,
    ProgressComponent
  ],
  templateUrl: './create-company-profile.component.html',
  styleUrls: ['./create-company-profile.component.css']
})
export class CreateCompanyProfileComponent {
  currentStep: number = 1;
  errors: Record<string, string> = {};

  formData: CompanyCreateFormData = {
    logo: '',
    location: '',
    size: '',
    foundedYear: null,
    description: '',
    website: '',
    linkedinUrl: '',
    contactEmail: '',
    technologies: []
  };

  newTech: string = '';

  sizeOptions: string[] = [
    '1-10 employees',
    '10-50 employees',
    '50-200 employees',
    '200-500 employees',
    '500+ employees'
  ];

  allTechnologies: string[] = [
    'JavaScript', 'TypeScript', 'Python', 'Java', 'C++', 'React', 'Angular',
    'Vue.js', 'Node.js', 'Express', 'Django', 'Spring Boot', 'Machine Learning',
    'Data Science', 'SQL', 'MongoDB', 'PostgreSQL', 'AWS', 'Docker', 'Kubernetes'
  ];

  steps: Step[] = [
    { id: 1, title: 'Basic Information', icon: 'building' },
    { id: 2, title: 'Details & Links', icon: 'link' }
  ];

  constructor(private router: Router) {}

  get progressValue(): number {
    return (this.currentStep / 2) * 100;
  }

  get suggestedTechs(): string[] {
    if (!this.newTech.trim()) return [];
    return this.allTechnologies
      .filter(tech =>
        !this.formData.technologies.includes(tech) &&
        tech.toLowerCase().includes(this.newTech.toLowerCase())
      )
      .slice(0, 5);
  }

  validateStep(step: number): boolean {
    const newErrors: Record<string, string> = {};

    if (step === 1) {
      if (!this.formData.location.trim()) {
        newErrors['location'] = 'Location is required';
      }
      if (!this.formData.size) {
        newErrors['size'] = 'Company size is required';
      }
      if (!this.formData.description.trim()) {
        newErrors['description'] = 'Description is required';
      } else if (this.formData.description.trim().length < 20) {
        newErrors['description'] = 'Description must be at least 20 characters';
      }
    }

    if (step === 2) {
      if (!this.formData.contactEmail.trim()) {
        newErrors['contactEmail'] = 'Contact email is required';
      }
    }

    this.errors = newErrors;
    return Object.keys(newErrors).length === 0;
  }

  handleNext(): void {
    if (this.validateStep(this.currentStep)) {
      this.currentStep = Math.min(this.currentStep + 1, 2);
    }
  }

  handleBack(): void {
    this.currentStep = Math.max(this.currentStep - 1, 1);
  }

  handleLogoUpload(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader();
      reader.onloadend = () => {
        this.formData.logo = reader.result as string;
      };
      reader.readAsDataURL(file);
      // TODO: Upload to server via service
    }
  }

  removeLogo(): void {
    this.formData.logo = '';
  }

  handleAddTech(): void {
    const tech = this.newTech.trim();
    if (tech && !this.formData.technologies.includes(tech)) {
      this.formData.technologies.push(tech);
      this.newTech = '';
    }
  }

  handleRemoveTech(tech: string): void {
    this.formData.technologies = this.formData.technologies.filter(t => t !== tech);
  }

  selectSuggestedTech(tech: string): void {
    this.formData.technologies.push(tech);
    this.newTech = '';
  }

  onTechKeyDown(event: KeyboardEvent): void {
    if (event.key === 'Enter') {
      event.preventDefault();
      this.handleAddTech();
    }
  }

  handleCreateProfile(): void {
    if (!this.validateStep(2)) return;

    // TODO: Replace with actual service call
    console.log('Creating company profile:', this.formData);

    this.router.navigate(['/profile']);
  }

  handleCancel(): void {
    this.router.navigate(['/']);
  }
}