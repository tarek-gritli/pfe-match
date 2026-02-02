import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { CardComponent, CardContentComponent, CardHeaderComponent, CardTitleComponent } from '../../Common/card/card.component';
import { ButtonComponent } from '../../Common/button/button.component';
import { InputComponent } from '../../Common/input/input.component';
import { TextareaComponent } from '../../Common/textarea/textarea.component';
import { LabelComponent } from '../../Common/label/label.component';
import { BadgeComponent } from '../../Common/badge/badge.component';

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

  sizeOptions: string[] = [
    '1-10 employees',
    '10-50 employees',
    '50-200 employees',
    '200-500 employees',
    '500+ employees'
  ];

  constructor(private router: Router) {}

  ngOnInit(): void {
    // TODO: Load enterprise data from service
    this.loadEnterpriseData();
  }

  loadEnterpriseData(): void {
    // TODO: Replace with actual service call
    this.formData = {
      name: 'TechCorp Solutions',
      industry: 'Software Development',
      location: 'Tunis, Tunisia',
      size: '50-200 employees',
      foundedYear: 2018,
      description: 'We build cutting-edge software solutions tailored to the needs of modern businesses. Passionate about innovation and technology-driven growth.',
      website: 'https://techcorp.com',
      linkedinUrl: 'https://linkedin.com/company/techcorp',
      contactEmail: 'contact@techcorp.com'
    };

    this.technologies = ['Angular', 'React', 'Node.js', 'PostgreSQL', 'AWS', 'Docker'];
    this.currentLogo = 'https://github.com/shadcn.png';
    this.logoPreview = this.currentLogo;
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

  handleLogoUpload(): void {
    // TODO: Implement actual file upload
    alert('Logo upload functionality coming soon!');
  }

  removeLogo(): void {
    this.logoPreview = '';
    this.currentLogo = '';
  }

  handleSave(): void {
    // TODO: Replace with actual service call
    const updatedProfile = {
      ...this.formData,
      technologies: this.technologies,
      logo: this.logoPreview
    };

    console.log('Saving company profile:', updatedProfile);

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