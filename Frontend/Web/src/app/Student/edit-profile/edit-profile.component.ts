import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { CardContainerComponent } from '../../components/card-container/card-container.component';
import { FormFieldComponent } from '../../components/form-field/form-field.component';

@Component({
  selector: 'app-student-edit-profile',
  standalone: true,
  imports: [CommonModule, FormsModule, CardContainerComponent],
  templateUrl: './edit-profile.component.html',
  styleUrls: ['./edit-profile.component.css']
})
export class EditProfileComponent {
  profileVisibility = 72;
  
  profileData = {
    name: 'Alexandre Dubois',
    university: 'Tech University of Munich',
    specialization: 'Software Engineering',
    bio: 'Passionate software engineering student specializing in cloud-native applications and AI integration. Looking for a 6-month PFE opportunity starting February 2024.',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC9D10QIt--py9-2R8pwT23fv-vWtFNzrVh-kZJFJsHE_npBGu18o9oBWQvctbFyVw9lsR3tbetRjXrkd-ScYW1dh06x3up4q8Tu5SmP3lDHz6hbLFdyIBKIQaH10jvtA_TGZIEzFUSqLXr5HIuFBX0afO07jkASUTUtH9ewSg-e1MzrXzzaeU-CHQJA1yCJF_r0VA40SuqAVnophnJSndNjMFrnb5S2u5okgemJV5vH9_oVkMawZtOWHt47VBOEaxmp1LEdabs-94',
    subtitle: 'Senior Student • Tech University'
  };

  coreSkills: string[] = ['Python', 'TypeScript', 'Node.js'];
  technologies: string[] = ['Docker', 'Kubernetes'];
  
  newCoreSkill = '';
  newTechnology = '';

  settings = {
    matchNotifications: true,
    profileVisible: true
  };

  resume = {
    filename: 'Resume_Alexandre_2023.pdf',
    uploadDate: 'Oct 24, 2023',
    size: '1.2 MB'
  };

  constructor(private router: Router) {}

  goBack(): void {
    this.router.navigate(['/profile']);
  }

  saveProfile(): void {
    console.log('Profile saved', this.profileData);
  }

  changeProfilePhoto(): void {
    console.log('Change profile photo');
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

  replaceResume(): void {
    console.log('Replace resume');
  }

  deleteResume(): void {
    console.log('Delete resume');
  }

  signOut(): void {
    console.log('Sign out');
  }
}