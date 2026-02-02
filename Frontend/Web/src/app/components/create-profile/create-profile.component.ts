import { Component } from '@angular/core';
import { CreateCompanyProfileComponent } from '../company/create-company-profile/create-company-profile.component';
import { CreateStudentProfileComponent } from '../student/create-student-profile/create-student-profile.component';

@Component({
  selector: 'app-create-profile',
  imports: [CreateCompanyProfileComponent, CreateStudentProfileComponent],
  templateUrl: './create-profile.component.html',
  standalone: true
})
export class CreateProfileComponent {
  accountType = localStorage.getItem('pfe_match_user_type');
}
