import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ButtonComponent } from '../../Common/button/button.component';
import { InputComponent } from '../../Common/input/input.component';
import { TextareaComponent } from '../../Common/textarea/textarea.component';
import { LabelComponent } from '../../Common/label/label.component';
import { CardComponent, CardContentComponent, CardDescriptionComponent, CardHeaderComponent, CardTitleComponent } from '../../Common/card/card.component';
import { BadgeComponent } from '../../Common/badge/badge.component';
import { ProgressComponent } from '../../Common/progress/progress.component';

interface ProfileFormData {
  profileImage: string;
  fullName: string;
  title: string;
  university: string;
  bio: string;
  skills: string[];
  technologies: string[];
  resumeName: string;
  linkedinUrl: string;
  githubUrl: string;
  customLinkLabel: string;
  customLinkUrl: string;
}

interface Step {
  id: number;
  title: string;
  icon: string;
}

@Component({
  selector: 'app-create-student-profile',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ButtonComponent,
    InputComponent,
    TextareaComponent,
    LabelComponent,
    CardComponent,
    CardContentComponent,
    CardDescriptionComponent,
    CardHeaderComponent,
    CardTitleComponent,
    BadgeComponent,
    ProgressComponent
  ],
  templateUrl: './create-student-profile.component.html',
  styleUrls: ['./create-student-profile.component.css']
})
export class CreateStudentProfileComponent {
  currentStep: number = 1;
  errors: Record<string, string> = {};

  formData: ProfileFormData = {
    profileImage: '',
    fullName: '',
    title: '',
    university: '',
    bio: '',
    skills: [],
    technologies: [],
    resumeName: '',
    linkedinUrl: '',
    githubUrl: '',
    customLinkLabel: '',
    customLinkUrl: ''
  };

  newSkill: string = '';
  newTech: string = '';

  // Mock data for suggestions
  allSkills: string[] = [
    'JavaScript', 'TypeScript', 'Python', 'Java', 'C++', 'React', 'Angular',
    'Vue.js', 'Node.js', 'Express', 'Django', 'Spring Boot', 'Machine Learning',
    'Data Science', 'SQL', 'MongoDB', 'PostgreSQL', 'AWS', 'Docker', 'Kubernetes'
  ];

  steps: Step[] = [
    { id: 1, title: 'Basic Information', icon: 'user' },
    { id: 2, title: 'Resume', icon: 'file-text' }
  ];

  constructor(private router: Router) { }

  get progressValue(): number {
    return (this.currentStep / 2) * 100;
  }

  get suggestedSkills(): string[] {
    return this.allSkills
      .filter(skill =>
        !this.formData.skills.includes(skill) &&
        skill.toLowerCase().includes(this.newSkill.toLowerCase())
      )
      .slice(0, 5);
  }

  get suggestedTechs(): string[] {
    return this.allSkills
      .filter(tech =>
        !this.formData.technologies.includes(tech) &&
        tech.toLowerCase().includes(this.newTech.toLowerCase())
      )
      .slice(0, 5);
  }

  validateStep(step: number): boolean {
    const newErrors: Record<string, string> = {};

    if (step === 1) {
      if (!this.formData.title.trim()) {
        newErrors['title'] = 'Desired job role is required';
      }
      if (!this.formData.bio.trim()) {
        newErrors['bio'] = 'Bio is required';
      } else if (this.formData.bio.trim().length < 20) {
        newErrors['bio'] = 'Bio must be at least 20 characters';
      }
    }

    if (step === 2) {
      // Only validate skills if resume is uploaded
      if (this.formData.resumeName && this.formData.skills.length === 0) {
        newErrors['skills'] = 'At least one skill is required';
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

  handleAddSkill(): void {
    const skill = this.newSkill.trim();
    if (skill && !this.formData.skills.includes(skill)) {
      this.formData.skills.push(skill);
      this.newSkill = '';
      delete this.errors['skills'];
    }
  }

  handleRemoveSkill(skill: string): void {
    this.formData.skills = this.formData.skills.filter(s => s !== skill);
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

  selectSuggestedSkill(skill: string): void {
    this.formData.skills.push(skill);
    this.newSkill = '';
    delete this.errors['skills'];
  }

  selectSuggestedTech(tech: string): void {
    this.formData.technologies.push(tech);
    this.newTech = '';
  }

  handleResumeUpload(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    if (file && file.type === 'application/pdf') {
      this.formData.resumeName = file.name;
    }
  }

  handleProfileImageUpload(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader();
      reader.onloadend = () => {
        this.formData.profileImage = reader.result as string;
      };
      reader.readAsDataURL(file);
    }
  }

  clearResume(): void {
    this.formData.resumeName = '';
  }

  handleCreateProfile(): void {
    if (!this.validateStep(2)) return;

    // TODO: Replace with actual service call
    console.log('Creating profile:', this.formData);

    // Navigate to profile page
    this.router.navigate(['/profile']);
  }

  onSkillKeyDown(event: KeyboardEvent): void {
    if (event.key === 'Enter') {
      event.preventDefault();
      this.handleAddSkill();
    }
  }

  onTechKeyDown(event: KeyboardEvent): void {
    if (event.key === 'Enter') {
      event.preventDefault();
      this.handleAddTech();
    }
  }
}