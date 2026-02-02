import { Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { CardComponent, CardContentComponent, CardHeaderComponent, CardTitleComponent } from '../../Common/card/card.component';
import { ButtonComponent } from '../../Common/button/button.component';
import { InputComponent } from '../../Common/input/input.component';
import { TextareaComponent } from '../../Common/textarea/textarea.component';
import { LabelComponent } from '../../Common/label/label.component';
import { BadgeComponent } from '../../Common/badge/badge.component';
import { Company, CompanyProfileUpdate } from '../../../models/company-profile.model';
import { CompanyService} from '../../../services/company.service';
import { inject } from '@angular/core';
import { AuthService } from '../../../auth/services/auth.service';



interface CompanyFormData {
  name: string;
  industry: string;
  location: string;
  size: string;
  foundedYear: number | null;
  description: string;
  website: string;
  linkedinUrl: string;
  contactEmail: string;
}

@Component({
  selector: 'app-edit-company-profile',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    CardComponent,
    CardContentComponent,
    CardHeaderComponent,
    CardTitleComponent,
    ButtonComponent,
    InputComponent,
    TextareaComponent,
    LabelComponent,
    BadgeComponent
  ],
  templateUrl: './edit-company-profile.component.html',
  styleUrls: ['./edit-company-profile.component.css']
})
export class EditCompanyProfileComponent implements OnInit {
  private companyService = inject(CompanyService);
  private authService = inject(AuthService);
  @ViewChild('logoInput') logoInput!: ElementRef;
  formData: CompanyFormData = {
    name: '',
    industry: '',
    location: '',
    size: '',
    foundedYear: null,
    description: '',
    website: '',
    linkedinUrl: '',
    contactEmail: ''
  };

  technologies: string[] = [];
  newTech: string = '';

  logoPreview: string = '';
  currentLogo: string = '';

  // Mock data for all technologies (for reference)
  allTechnologies: string[] = [
    'JavaScript', 'TypeScript', 'Python', 'Java', 'C++', 'React', 'Angular',
    'Vue.js', 'Node.js', 'Express', 'Django', 'Spring Boot', 'Machine Learning',
    'Data Science', 'SQL', 'MongoDB', 'PostgreSQL', 'AWS', 'Docker', 'Kubernetes'
  ];

  industryOptions: string[] = [
    'Software Development', 'Fintech', 'Healthcare', 'E-Commerce',
    'Cybersecurity', 'Telecom', 'Education', 'Energy', 'Logistics', 'Other'
  ];

  currentEnterprise: Company = {
    name: '',
    industry: '',
    location: '',
    size: '',
    technologies: [],
    contactEmail: '',
  };

  sizeOptions: string[] = [
    '1-10 employees',
    '10-50 employees',
    '50-200 employees',
    '200-500 employees',
    '500+ employees'
  ];

  isLoading = false;
  errors: Record<string, string> = {};

  constructor(private router: Router) {}

  ngOnInit(): void {
    this.companyService.getProfile().subscribe({
      next: (company) => {
  this.currentEnterprise = company;
  this.formData = {
    name: this.currentEnterprise.name,
    industry: this.currentEnterprise.industry,
    location: this.currentEnterprise.location,
    size: this.currentEnterprise.size,
    foundedYear: this.currentEnterprise.foundedYear || 0,
    description: this.currentEnterprise.description || '',
    website: this.currentEnterprise.website || '',
    linkedinUrl: this.currentEnterprise.linkedinUrl || '',
    contactEmail: this.currentEnterprise.contactEmail
  };
  this.technologies = this.currentEnterprise.technologies;
  this.currentLogo = this.currentEnterprise.logo!;

  // This is the only line you need to add:
  this.logoPreview = this.getProfileImageUrl(this.currentEnterprise.logo);
},
      error: () => {
        this.isLoading = false;
      }
    })
  }

    getProfileImageUrl(path: string | undefined): string {
      return this.companyService.getProfileImageUrl(path);
    }
    isUploadingLogo = false;



triggerLogoUpload(): void {
  this.logoInput.nativeElement.click();
}

handleLogoUpload(event: Event): void {
  const input = event.target as HTMLInputElement;
  const file = input.files?.[0];

  if (file && file.type.startsWith('image/')) {
    delete this.errors['logo'];

    // Show preview immediately
    const reader = new FileReader();
    reader.onloadend = () => {
      this.logoPreview = reader.result as string;
    };
    reader.onerror = () => {
      this.errors['logo'] = 'Failed to read image file';
    };
    reader.readAsDataURL(file);

    // Upload to server
    this.isUploadingLogo = true;
    this.authService.uploadCompanyLogo(file).subscribe({
      next: (response) => {
        this.isUploadingLogo = false;
        this.logoPreview = this.getProfileImageUrl(response.profile_picture_url); // adjust key to match your API response
      },
      error: (error) => {
        this.isUploadingLogo = false;
        this.errors['logo'] = error.message || 'Failed to upload logo';
        this.logoPreview = this.getProfileImageUrl(this.currentEnterprise.logo); // revert to existing
        input.value = '';
      }
    });
  } else if (file) {
    this.errors['logo'] = 'Please select a valid image file';
  }
}
  addTechnology(): void {
    const tech = this.newTech.trim();
    if (tech && !this.technologies.includes(tech)) {
      this.technologies.push(tech);
      this.newTech = '';
    }
  }

  removeTechnology(tech: string): void {
    this.technologies = this.technologies.filter(t => t !== tech);
  }

  onTechKeyPress(event: KeyboardEvent): void {
    if (event.key === 'Enter') {
      event.preventDefault();
      this.addTechnology();
    }
  }

  removeLogo(): void {
    this.logoPreview = '';
    this.currentLogo = '';
  }

  handleSave(): void {
    const payload: CompanyProfileUpdate = {
      company_name: this.formData.name,
      industry: this.formData.industry,
      location: this.formData.location,
      employee_count: this.formData.size,
      founded_year: this.formData.foundedYear || undefined,
      company_description: this.formData.description,
      website: this.formData.website || undefined,
      linkedin_url: this.formData.linkedinUrl || undefined,
      technologies_used: this.technologies,
    };
    this.companyService.updateMyProfile(payload).subscribe({
      next: () => {
        alert('Profile updated successfully!');
        this.router.navigate(['/profile']);
      },
      error: (err : any) => {
        console.error(err);
        alert('Failed to update profile');
      }
    });
    // Show success message (you can integrate a toast service here)
    alert('Company profile updated successfully!');

    this.router.navigate(['/profile']);
  }

  handleCancel(): void {
    this.router.navigate(['/profile']);
  }

  navigateBack(): void {
    this.router.navigate(['/profile']);
  }

  get availableTechnologies(): string[] {
    return this.allTechnologies.filter(t => !this.technologies.includes(t));
  }
}