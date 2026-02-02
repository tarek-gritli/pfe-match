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
import { StudentService } from '../../../services/student.service';
import { inject } from '@angular/core';
import { Student } from '../../../models/student-profile.model';
import { AuthService} from '../../../auth/services/auth.service';
import { ResumeExtractedData } from '../../../auth/model/auth.model';
import { ViewChild, ElementRef } from '@angular/core';

interface FormData {
  firstName: string;
  lastName: string;
  email: string;
  university: string;
  fieldOfStudy: string;
  title: string;
  bio: string;
  linkedinUrl: string;
  githubUrl: string;
  customLinkLabel: string;
  customLinkUrl: string;
}

@Component({
  selector: 'app-edit-student-profile',
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
  templateUrl: './edit-student-profile.component.html',
  styleUrls: ['./edit-student-profile.component.css']
})
export class EditStudentProfileComponent implements OnInit {
  private studentService = inject(StudentService);
  private authService = inject(AuthService);
  currentStudent: Student = {
    firstName: '',
    lastName: '',
    university: '',
    skills: [],
    technologies: [],
    fieldOfStudy: '',
    bio: '',
  };

  @ViewChild('resumeFileInput') resumeFileInput!: ElementRef<HTMLInputElement>;

  isUploadingResume: any;
  private extractedData: any;
  isUploadingImage: any;
  private resumeFile: any;
  resumeName: any;
  errors: Record<string, string> = {};

  formData: FormData = {
    firstName: '',
    lastName: '',
    email: '',
    university: '',
    fieldOfStudy: '',
    title: '',
    bio: '',
    linkedinUrl: '',
    githubUrl: '',
    customLinkLabel: '',
    customLinkUrl: ''
  };

  skills: string[] = [];
  technologies: string[] = [];
  newSkill: string = '';
  newTech: string = '';

  // Mock data for all skills (for autocomplete)
  allSkills: string[] = [
    'JavaScript', 'TypeScript', 'Python', 'Java', 'C++', 'React', 'Angular',
    'Vue.js', 'Node.js', 'Express', 'Django', 'Spring Boot', 'Machine Learning',
    'Data Science', 'SQL', 'MongoDB', 'PostgreSQL', 'AWS', 'Docker', 'Kubernetes'
  ];

  isLoading = true;

  /**
   * Extract just the filename from a full path for display
   */
  getResumeDisplayName(): string {
    if (!this.resumeName) return '';
    const pathParts = this.resumeName.replace(/\\/g, '/').split('/');
    return pathParts[pathParts.length - 1];
  }

  constructor(private router: Router) {}

  ngOnInit(): void {
    this.studentService.getProfile().subscribe({
      next: (student) => {
        this.currentStudent = student;
        this.formData = {
        firstName: this.currentStudent.firstName,
        lastName: this.currentStudent.lastName,
        email: localStorage.getItem('pfe_match_email') || '',
        university: this.currentStudent.university,
        fieldOfStudy: this.currentStudent.fieldOfStudy,
        title: this.currentStudent.title || '',
        bio: this.currentStudent.bio,
        linkedinUrl: this.currentStudent.linkedinUrl || '',
        githubUrl: this.currentStudent.githubUrl || '',
        customLinkLabel: this.currentStudent.customLinkLabel || 'Portfolio',
        customLinkUrl: this.currentStudent.customLinkUrl || ''
      };

    // Use actual student data, not hardcoded values
    this.skills = this.currentStudent.skills || [];
    this.technologies = this.currentStudent.technologies || [];
    this.resumeName = this.currentStudent.resumeName || null;
    this.isLoading = false;
      },
      error: () => {
        this.isLoading = false;
      }
    })
    
  }

  addSkill(): void {
    const skill = this.newSkill.trim();
    if (skill && !this.skills.includes(skill)) {
      this.skills.push(skill);
      this.newSkill = '';
    }
  }

  removeSkill(skill: string): void {
    this.skills = this.skills.filter(s => s !== skill);
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

  handleSave(): void {
  const payload = {
    university: this.formData.university,
    short_bio: this.formData.bio,
    desired_job_role: this.formData.title,
    linkedin_url: this.formData.linkedinUrl,
    github_url: this.formData.githubUrl,
    portfolio_url: this.formData.customLinkUrl,
    skills: this.skills,
    technologies: this.technologies
  };

  this.studentService.updateMyProfile(payload).subscribe({
    next: () => {
      alert('Profile updated successfully!');
      this.router.navigate(['/profile']);
    },
    error: (err : any) => {
      console.error(err);
      alert('Failed to update profile');
    }
  });
}

  triggerFileInput(): void {
    this.resumeFileInput.nativeElement.click();
  }

  handleResumeUpload(event: Event): void {
      const input = event.target as HTMLInputElement;
      const file = input.files?.[0];
      if (file && file.type === 'application/pdf') {
        this.resumeFile = file;
        this.resumeName = file.name;
        this.isUploadingResume = true;
  
        // Upload resume and extract data
        this.authService.uploadResume(file).subscribe({
          next: (response) => {
            this.isUploadingResume = false;
  
            if (response.extracted_data) {
              this.extractedData = response.extracted_data as ResumeExtractedData;
  
              // Always update with extracted data from new resume
              if (this.extractedData.github_url) {
                this.formData.githubUrl = this.extractedData.github_url;
              }
              if (this.extractedData.linkedin_url) {
                this.formData.linkedinUrl = this.extractedData.linkedin_url;
              }
              // Always replace skills and technologies with new extracted data
              if (this.extractedData.skills?.length) {
                this.skills = [...this.extractedData.skills];
              }
              if (this.extractedData.technologies?.length) {
                this.technologies = [...this.extractedData.technologies];
              }
              
              alert('Resume uploaded! Skills and technologies have been updated from your CV.');
            }
          },
          error: (error) => {
            this.isUploadingResume = false;
            this.errors['resume'] = error.message || 'Failed to upload resume';
          }
        });
      }
    }

  handleCancel(): void {
    this.router.navigate(['/profile']);
  }

  navigateBack(): void {
    this.router.navigate(['/profile']);
  }

  onSkillKeyPress(event: KeyboardEvent): void {
    if (event.key === 'Enter') {
      event.preventDefault();
      this.addSkill();
    }
  }

  onTechKeyPress(event: KeyboardEvent): void {
    if (event.key === 'Enter') {
      event.preventDefault();
      this.addTechnology();
    }
  }

  get availableSkills(): string[] {
    return this.allSkills.filter(s => !this.skills.includes(s));
  }
}