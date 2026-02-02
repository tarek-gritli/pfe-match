import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { CardComponent, CardContentComponent, CardHeaderComponent, CardTitleComponent } from '../../Common/card/card.component';
import { ButtonComponent } from '../../Common/button/button.component';
import { BadgeComponent } from '../../Common/badge/badge.component';
import { ProgressComponent } from '../../Common/progress/progress.component';
import { AvatarComponent } from '../../Common/avatar/avatar.component';
import { Student } from '../../../models/student-profile.model';
import { StudentService } from '../../../services/student.service';
import { inject } from '@angular/core';

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
    firstName: '',
    lastName: '',
    university: '',
    skills: [],
    technologies: [],
    fieldOfStudy: '',
    bio: '',
  };

  profileCompleteness: ProfileCompleteness = {
    percentage: 0,
    tip: ''
  };

  private studentService = inject(StudentService);
  isLoading = true;

  constructor(private router: Router) {}

  ngOnInit(): void {
    this.studentService.getProfile().subscribe({
      next: (student) => {
        this.currentStudent = student;
        console.log(this.currentStudent.profileImage);
        this.profileCompleteness = this.calculateProfileCompleteness(this.currentStudent);
      },
      error: () => {
        this.isLoading = false;
      }
    })
  }

  getProfileImageUrl(path: string | undefined): string {
    return this.studentService.getProfileImageUrl(path);
  }

  calculateProfileCompleteness(student: Student): ProfileCompleteness {
    let completed = 0;
    let total = 0;
    const tips: string[] = [];

    // Basic info (40 points)
    total += 10;
    if (student.firstName) completed += 10;
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