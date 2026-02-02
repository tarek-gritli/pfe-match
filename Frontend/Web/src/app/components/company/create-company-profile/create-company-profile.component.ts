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
import { Company, CompanyProfileUpdate } from '../../../models/company-profile.model';
import { CompanyService} from '../../../services/company.service';
import { inject } from '@angular/core';
import { AuthService } from '../../../auth/services/auth.service';


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
  private companyService = inject(CompanyService);
  private authService = inject(AuthService);
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

  isUploadingImage: any;
  profileImageFile: any;

  imagePreview: string | null = null;


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

  handleProfileImageUpload(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    
    if (file && file.type.startsWith('image/')) {
      // Clear any previous errors
      delete this.errors['profileImage'];
      
      this.profileImageFile = file;

      // Show preview immediately
      const reader = new FileReader();
      reader.onloadend = () => {
        this.imagePreview = reader.result as string;
        console.log('Preview set:', this.imagePreview?.substring(0, 50)); // Debug
      };
      reader.onerror = () => {
        this.errors['profileImage'] = 'Failed to read image file';
        console.error('FileReader error'); // Debug
      };
      reader.readAsDataURL(file);

      // Upload to server
      this.isUploadingImage = true;
      this.authService.uploadStudentProfilePicture(file).subscribe({
        next: (response) => {
          this.isUploadingImage = false;
          console.log('Upload successful:', response); // Debug
          // Update with server URL
          this.formData.logo = response.profile_picture_url;
          // Keep preview until server image loads, then clear
          //setTimeout(() => {
          //  this.imagePreview = null;
          //}, 100);
        },
        error: (error) => {
          this.isUploadingImage = false;
          this.errors['profileImage'] = error.message || 'Failed to upload image';
          // Clear preview on error
          this.imagePreview = null;
          this.profileImageFile = null;
          // Reset input
          input.value = '';
        }
      });
    } else if (file) {
      this.errors['profileImage'] = 'Please select a valid image file';
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
    const payload: CompanyProfileUpdate = {
      location: this.formData.location,
      employee_count: this.formData.size,
      founded_year: this.formData.foundedYear || undefined,
      company_description: this.formData.description,
      website: this.formData.website || undefined,
      linkedin_url: this.formData.linkedinUrl || undefined,
      technologies_used: this.formData.technologies,
    };
    this.companyService.updateMyProfile(payload).subscribe({
      next: () => {
        alert('Profile updated successfully!');
        this.router.navigate(['/profile']);
      },
      error: (err : any) => {
        console.error(err);
        alert('Failed to create profile');
      }
    });

    console.log('Creating company profile:', this.formData);
  }

  handleCancel(): void {
    this.router.navigate(['/']);
  }
}