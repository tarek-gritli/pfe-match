import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { CardContainerComponent } from '../../components/card-container/card-container.component';
import { StudentProfile } from '../../models/student-profile.model';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-student-profile',
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.css'],
  standalone: true,
  imports: [CardContainerComponent]
})
export class ProfileComponent implements OnInit {

  profileIntegrity!: number;
  profileData!: StudentProfile['profile'];
  skills: StudentProfile['skills'] = [];
  tools: StudentProfile['tools'] = [];
  resume!: StudentProfile['resume'];

  constructor(private router: Router, private http: HttpClient) {}

  ngOnInit(): void {
    // Fetch student profile from backend
    this.http.get<StudentProfile>('http://localhost:8000/students/me')
      .subscribe({
        next: (data) => {
          this.profileIntegrity = data.profileIntegrity;
          this.profileData = data.profile;
          this.skills = data.skills;
          this.tools = data.tools;
          this.resume = data.resume;
          console.log('Student profile loaded');
        },
        error: (err) => {
          console.error('Failed to load student profile', err);
        }
      });
  }

  navigateToEditProfile(): void {
    this.router.navigate(['/edit-profile']);
  }

  downloadResume(): void {
    console.log('Download resume');
  }
}