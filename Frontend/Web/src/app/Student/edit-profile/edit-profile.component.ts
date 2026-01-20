import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { CardContainerComponent } from '../../components/card-container/card-container.component';
import { StudentProfile } from '../../models/student-profile.model';

@Component({
  selector: 'app-student-edit-profile',
  standalone: true,
  imports: [CommonModule, FormsModule, CardContainerComponent],
  templateUrl: './edit-profile.component.html',
  styleUrls: ['./edit-profile.component.css']
})
export class EditProfileComponent implements OnInit {
  profileIntegrity: number = 0;
  
  profileData = {
    name: '',
    title: '',
    university: '',
    location: '',
    summary: '',
    imageUrl: ''
  };

  skills: Array<{name: string}> = [];
  tools: Array<{name: string}> = [];
  
  newSkill = '';
  newTool = '';

  resume: StudentProfile['resume'] | null = null;

  isLoading = true;

  constructor(private router: Router, private http: HttpClient) {}

  ngOnInit(): void {
    // Fetch student profile from backend
    this.http.get<StudentProfile>('http://localhost:8000/students/me')
      .subscribe({
        next: (data) => {
          this.profileIntegrity = data.profileIntegrity;
          this.profileData = {
            name: data.profile.name,
            title: data.profile.title,
            university: data.profile.university,
            location: data.profile.location,
            summary: data.profile.summary,
            imageUrl: data.profile.imageUrl
          };
          this.skills = [...data.skills];
          this.tools = [...data.tools];
          this.resume = data.resume;
          this.isLoading = false;
          console.log('Student profile loaded for editing');
        },
        error: (err) => {
          console.error('Failed to load student profile', err);
          this.isLoading = false;
        }
      });
  }

  goBack(): void {
    this.router.navigate(['/profile']);
  }

  saveProfile(): void {
    const updates = {
      profileIntegrity: this.profileIntegrity,
      profile: {
        name: this.profileData.name,
        title: this.profileData.title,
        university: this.profileData.university,
        location: this.profileData.location,
        summary: this.profileData.summary,
        imageUrl: this.profileData.imageUrl
      },
      skills: this.skills,
      tools: this.tools,
      resume: this.resume
    };

    this.http.post('http://localhost:8000/students/me', updates)
      .subscribe({
        next: (response) => {
          console.log('Profile saved successfully', response);
          // Optionally navigate back to profile page
          this.router.navigate(['/profile']);
        },
        error: (err) => {
          console.error('Failed to save profile', err);
        }
      });
  }

  changeProfilePhoto(): void {
    // TODO: Implement file upload
    console.log('Change profile photo');
  }

  addSkill(): void {
    if (this.newSkill.trim()) {
      this.skills.push({ name: this.newSkill.trim() });
      this.newSkill = '';
    }
  }

  removeSkill(skill: {name: string}): void {
    this.skills = this.skills.filter(s => s.name !== skill.name);
  }

  addTool(): void {
    if (this.newTool.trim()) {
      this.tools.push({ name: this.newTool.trim() });
      this.newTool = '';
    }
  }

  removeTool(tool: {name: string}): void {
    this.tools = this.tools.filter(t => t.name !== tool.name);
  }

  replaceResume(): void {
    // TODO: Implement file upload
    console.log('Replace resume');
  }

  deleteResume(): void {
    this.resume = null;
  }
}