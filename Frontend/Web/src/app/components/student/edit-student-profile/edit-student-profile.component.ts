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

interface FormData {
  fullName: string;
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
  formData: FormData = {
    fullName: '',
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

  // Mock data for current student
  currentStudent = {
    resumeName: '',
    resumeUploadDate: ''
  };

  // Mock data for all skills (for autocomplete)
  allSkills: string[] = [
    'JavaScript', 'TypeScript', 'Python', 'Java', 'C++', 'React', 'Angular',
    'Vue.js', 'Node.js', 'Express', 'Django', 'Spring Boot', 'Machine Learning',
    'Data Science', 'SQL', 'MongoDB', 'PostgreSQL', 'AWS', 'Docker', 'Kubernetes'
  ];

  constructor(private router: Router) {}

  ngOnInit(): void {
    // TODO: Load current student data from service
    this.loadStudentData();
  }

  loadStudentData(): void {
    // TODO: Replace with actual service call
    this.formData = {
      fullName: 'John Doe',
      email: 'john.doe@university.fr',
      university: 'Example University',
      fieldOfStudy: 'Computer Science',
      title: 'Software Engineering Student',
      bio: 'Passionate about building innovative software solutions and learning new technologies.',
      linkedinUrl: 'https://linkedin.com/in/johndoe',
      githubUrl: 'https://github.com/johndoe',
      customLinkLabel: 'Portfolio',
      customLinkUrl: 'https://johndoe.com'
    };

    this.skills = ['JavaScript', 'TypeScript', 'Angular', 'React', 'Node.js'];
    this.technologies = ['Git', 'Docker', 'AWS', 'MongoDB', 'PostgreSQL'];
    
    this.currentStudent = {
      resumeName: 'John_Doe_Resume.pdf',
      resumeUploadDate: '2024-01-15'
    };
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
    // TODO: Replace with actual service call
    const updatedProfile = {
      ...this.formData,
      skills: this.skills,
      technologies: this.technologies
    };
    
    console.log('Saving profile:', updatedProfile);
    
    // Show success message (you can integrate a toast service here)
    alert('Profile updated successfully!');
    
    this.router.navigate(['/profile']);
  }

  handleResumeUpload(): void {
    // TODO: Implement actual file upload
    const today = new Date().toISOString().split('T')[0];
    this.currentStudent.resumeName = 'new_resume.pdf';
    this.currentStudent.resumeUploadDate = today;
    
    // Show success message
    alert('Resume uploaded successfully!');
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