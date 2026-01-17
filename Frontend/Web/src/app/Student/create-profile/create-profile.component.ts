import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-create-profile',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './create-profile.component.html',
  styleUrls: ['./create-profile.component.css']
})
export class CreateProfileComponent {
  currentStep = 0;
  
  profileData = {
    name: '',
    university: '',
    specialization: '',
    location: '',
    bio: ''
  };

  coreSkills: string[] = [];
  technologies: string[] = [];
  
  newCoreSkill = '';
  newTechnology = '';
  
  profileImagePath: string | null = null;
  resumePath: string | null = null;

  steps = [
    {
      title: 'Basic Information',
      subtitle: 'Tell us about your academic background'
    },
    {
      title: 'About You',
      subtitle: 'Share your story and aspirations'
    },
    {
      title: 'Skills & Expertise',
      subtitle: 'Showcase your technical abilities'
    },
    {
      title: 'Finishing Touches',
      subtitle: 'Add your photo and resume'
    }
  ];

  constructor(private router: Router) {}

  nextStep(): void {
    if (this.currentStep < 3) {
      this.currentStep++;
    } else {
      this.completeProfileCreation();
    }
  }

  previousStep(): void {
    if (this.currentStep > 0) {
      this.currentStep--;
    }
  }

  skipProfileCreation(): void {
    this.router.navigate(['/profile']);
  }

  completeProfileCreation(): void {
    console.log('Profile created:', {
      ...this.profileData,
      coreSkills: this.coreSkills,
      technologies: this.technologies,
      profileImagePath: this.profileImagePath,
      resumePath: this.resumePath
    });
    
    // Show success message or navigate
    this.router.navigate(['/profile']);
  }

  canProceed(): boolean {
    switch (this.currentStep) {
      case 0:
        return !!(this.profileData.name && 
                 this.profileData.university && 
                 this.profileData.specialization);
      case 1:
        return !!(this.profileData.bio && this.profileData.location);
      case 2:
        return this.coreSkills.length > 0;
      case 3:
        return true;
      default:
        return false;
    }
  }

  addCoreSkill(): void {
    if (this.newCoreSkill.trim()) {
      this.coreSkills.push(this.newCoreSkill.trim());
      this.newCoreSkill = '';
    }
  }

  removeCoreSkill(skill: string): void {
    this.coreSkills = this.coreSkills.filter(s => s !== skill);
  }

  addTechnology(): void {
    if (this.newTechnology.trim()) {
      this.technologies.push(this.newTechnology.trim());
      this.newTechnology = '';
    }
  }

  removeTechnology(tech: string): void {
    this.technologies = this.technologies.filter(t => t !== tech);
  }

  selectProfileImage(): void {
    // Handle file selection
    console.log('Select profile image');
    this.profileImagePath = 'selected';
  }

  selectResume(): void {
    // Handle file selection
    console.log('Select resume');
    this.resumePath = 'selected';
  }
}