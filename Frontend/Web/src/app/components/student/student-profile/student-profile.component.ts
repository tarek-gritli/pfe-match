import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { CardComponent, CardContentComponent, CardHeaderComponent, CardTitleComponent } from '../../Common/card/card.component';
import { ButtonComponent } from '../../Common/button/button.component';
import { BadgeComponent } from '../../Common/badge/badge.component';
import { ProgressComponent } from '../../Common/progress/progress.component';
import { AvatarComponent } from '../../Common/avatar/avatar.component';

interface Student {
  fullName: string;
  profileImage?: string;
  title?: string;
  university: string;
  fieldOfStudy?: string;
  bio?: string;
  skills: string[];
  technologies: string[];
  linkedinUrl?: string;
  githubUrl?: string;
  customLinkUrl?: string;
  customLinkLabel?: string;
  resumeName?: string;
  resumeUploadDate?: string;
}

interface ProfileCompleteness {
  percentage: number;
  tip: string;
}

@Component({
  selector: 'app-student-profile',
  standalone: true,
  imports: [
    CommonModule,
    CardComponent,
    CardContentComponent,
    CardHeaderComponent,
    CardTitleComponent,
    ButtonComponent,
    BadgeComponent,
    ProgressComponent,
    AvatarComponent
  ],
  templateUrl: './student-profile.component.html',
  styleUrls: ['./student-profile.component.css']
})
export class StudentProfileComponent implements OnInit {
  currentStudent: Student = {
    fullName: '',
    university: '',
    skills: [],
    technologies: []
  };

  profileCompleteness: ProfileCompleteness = {
    percentage: 0,
    tip: ''
  };

  constructor(private router: Router) {}

  ngOnInit(): void {
    // TODO: Load current student data from your service
    // For now, using mock data
    this.loadStudentData();
    this.profileCompleteness = this.calculateProfileCompleteness(this.currentStudent);
  }

  loadStudentData(): void {
    // TODO: Replace with actual service call
    this.currentStudent = {
      fullName: 'John Doe',
      profileImage: 'https://github.com/shadcn.png',
      title: 'Software Engineering Student',
      university: 'Example University',
      fieldOfStudy: 'Computer Science',
      bio: 'Passionate about building innovative software solutions and learning new technologies.',
      skills: ['JavaScript', 'TypeScript', 'Angular', 'React', 'Node.js'],
      technologies: ['Git', 'Docker', 'AWS', 'MongoDB', 'PostgreSQL'],
      linkedinUrl: 'https://linkedin.com/in/johndoe',
      githubUrl: 'https://github.com/johndoe',
      customLinkUrl: 'https://johndoe.com',
      customLinkLabel: 'Portfolio',
      resumeName: 'John_Doe_Resume.pdf',
      resumeUploadDate: '2024-01-15'
    };
  }

  calculateProfileCompleteness(student: Student): ProfileCompleteness {
    let completed = 0;
    let total = 0;
    const tips: string[] = [];

    // Basic info (40 points)
    total += 10;
    if (student.fullName) completed += 10;
    else tips.push('Add your full name');

    total += 10;
    if (student.university) completed += 10;
    else tips.push('Add your university');

    total += 10;
    if (student.title) completed += 10;
    else tips.push('Add a professional title');

    total += 10;
    if (student.bio) completed += 10;
    else tips.push('Write a bio about yourself');

    // Skills and technologies (30 points)
    total += 15;
    if (student.skills.length > 0) completed += 15;
    else tips.push('Add your skills');

    total += 15;
    if (student.technologies.length > 0) completed += 15;
    else tips.push('Add technologies you know');

    // Links (20 points)
    total += 10;
    if (student.linkedinUrl) completed += 10;
    else tips.push('Add your LinkedIn profile');

    total += 10;
    if (student.githubUrl) completed += 10;
    else tips.push('Add your GitHub profile');

    // Resume (10 points)
    total += 10;
    if (student.resumeName) completed += 10;
    else tips.push('Upload your resume');

    const percentage = Math.round((completed / total) * 100);
    const tip = tips.length > 0 ? tips[0] : 'Your profile is complete!';

    return { percentage, tip };
  }

  getInitials(name: string): string {
    return name
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase();
  }

  navigateToEdit(): void {
    this.router.navigate(['/profile/edit']);
  }

  downloadResume(): void {
    // TODO: Implement resume download
    console.log('Download resume');
  }

  openLink(url: string): void {
    window.open(url, '_blank', 'noopener,noreferrer');
  }
}