import { Component, OnInit } from '@angular/core';
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
import { AuthService } from '../../../auth/services/auth.service';
import { StudentProfileUpdate, ResumeExtractedData } from '../../../auth/model/auth.model';

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
  portfolioUrl: string;
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
export class CreateStudentProfileComponent implements OnInit {
  currentStep: number = 1;
  errors: Record<string, string> = {};
  isLoading = false;
  isUploadingResume = false;
  isUploadingImage = false;
  resumeFile: File | null = null;
  profileImageFile: File | null = null;
  extractedData: ResumeExtractedData | null = null;

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
    portfolioUrl: '',
    customLinkLabel: '',
    customLinkUrl: ''
  };

  newSkill: string = '';
  newTech: string = '';

  // Suggestions for skills and technologies
  allSkills: string[] = [
    'JavaScript', 'TypeScript', 'Python', 'Java', 'C++', 'React', 'Angular',
    'Vue.js', 'Node.js', 'Express', 'Django', 'Spring Boot', 'Machine Learning',
    'Data Science', 'SQL', 'MongoDB', 'PostgreSQL', 'AWS', 'Docker', 'Kubernetes'
  ];

  steps: Step[] = [
    { id: 1, title: 'Basic Information', icon: 'user' },
    { id: 2, title: 'Skills & Tools', icon: 'briefcase' },
    { id: 3, title: 'Resume & Links', icon: 'file-text' }
  ];

  constructor(
    private router: Router,
    private authService: AuthService
  ) { }

  ngOnInit(): void {
    // Load existing profile data if available
    this.loadExistingProfile();
  }

  private loadExistingProfile(): void {
    this.authService.getStudentProfile().subscribe({
      next: (profile) => {
        this.formData.fullName = `${profile.first_name} ${profile.last_name}`;
        if (profile.university) this.formData.university = profile.university;
        if (profile.short_bio) this.formData.bio = profile.short_bio;
        if (profile.desired_job_role) this.formData.title = profile.desired_job_role;
        if (profile.linkedin_url) this.formData.linkedinUrl = profile.linkedin_url;
        if (profile.github_url) this.formData.githubUrl = profile.github_url;
        if (profile.portfolio_url) this.formData.portfolioUrl = profile.portfolio_url;
        if (profile.skills) this.formData.skills = profile.skills;
        if (profile.technologies) this.formData.technologies = profile.technologies;
        if (profile.profile_picture) this.formData.profileImage = profile.profile_picture;
      },
      error: (error) => {
        console.log('Could not load existing profile:', error.message);
      }
    });
  }

  get progressValue(): number {
    return (this.currentStep / 3) * 100;
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
      if (!this.formData.fullName.trim()) {
        newErrors['fullName'] = 'Full name is required';
      }
      if (!this.formData.title.trim()) {
        newErrors['title'] = 'Desired job role is required';
      }
      if (!this.formData.university.trim()) {
        newErrors['university'] = 'University is required';
      }
      if (!this.formData.bio.trim()) {
        newErrors['bio'] = 'Bio is required';
      } else if (this.formData.bio.trim().length < 20) {
        newErrors['bio'] = 'Bio must be at least 20 characters';
      }
    }

    if (step === 2) {
      if (this.formData.skills.length === 0) {
        newErrors['skills'] = 'At least one skill is required';
      }
    }

    this.errors = newErrors;
    return Object.keys(newErrors).length === 0;
  }

  handleNext(): void {
    if (this.validateStep(this.currentStep)) {
      this.currentStep = Math.min(this.currentStep + 1, 3);
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
      this.resumeFile = file;
      this.formData.resumeName = file.name;
      this.isUploadingResume = true;

      // Upload resume and extract data
      this.authService.uploadResume(file).subscribe({
        next: (response) => {
          this.isUploadingResume = false;

          if (response.extracted_data) {
            this.extractedData = response.extracted_data as ResumeExtractedData;

            // Pre-fill extracted data if fields are empty
            if (this.extractedData.github_url && !this.formData.githubUrl) {
              this.formData.githubUrl = this.extractedData.github_url;
            }
            if (this.extractedData.linkedin_url && !this.formData.linkedinUrl) {
              this.formData.linkedinUrl = this.extractedData.linkedin_url;
            }
            if (this.extractedData.skills?.length && this.formData.skills.length === 0) {
              this.formData.skills = [...this.extractedData.skills];
            }
            if (this.extractedData.technologies?.length && this.formData.technologies.length === 0) {
              this.formData.technologies = [...this.extractedData.technologies];
            }
          }
        },
        error: (error) => {
          this.isUploadingResume = false;
          this.errors['resume'] = error.message || 'Failed to upload resume';
        }
      });
    }
  }

  handleProfileImageUpload(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    if (file && file.type.startsWith('image/')) {
      this.profileImageFile = file;

      // Show preview immediately
      const reader = new FileReader();
      reader.onloadend = () => {
        this.formData.profileImage = reader.result as string;
      };
      reader.readAsDataURL(file);

      // Upload to server
      this.isUploadingImage = true;
      this.authService.uploadStudentProfilePicture(file).subscribe({
        next: (response) => {
          this.isUploadingImage = false;
          this.formData.profileImage = response.profile_picture_url;
        },
        error: (error) => {
          this.isUploadingImage = false;
          this.errors['profileImage'] = error.message || 'Failed to upload image';
        }
      });
    }
  }

  clearResume(): void {
    this.formData.resumeName = '';
    this.resumeFile = null;
    this.extractedData = null;
  }

  handleCreateProfile(): void {
    if (!this.validateStep(3)) return;

    this.isLoading = true;

    const profileData: StudentProfileUpdate = {
      university: this.formData.university,
      short_bio: this.formData.bio,
      desired_job_role: this.formData.title,
      linkedin_url: this.formData.linkedinUrl || undefined,
      github_url: this.formData.githubUrl || undefined,
      portfolio_url: this.formData.portfolioUrl || undefined,
      skills: this.formData.skills,
      technologies: this.formData.technologies
    };

    this.authService.updateStudentProfile(profileData).subscribe({
      next: () => {
        this.isLoading = false;
        this.router.navigate(['/profile']);
      },
      error: (error) => {
        this.isLoading = false;
        this.errors['submit'] = error.message || 'Failed to create profile';
      }
    });
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