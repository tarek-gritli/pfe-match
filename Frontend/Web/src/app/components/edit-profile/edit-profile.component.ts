import { Component } from '@angular/core';
import { EditCompanyProfileComponent } from '../company/edit-company-profile/edit-company-profile.component';
import { EditStudentProfileComponent } from '../student/edit-student-profile/edit-student-profile.component';

@Component({
  selector: 'app-edit-profile',
  imports: [  EditCompanyProfileComponent, EditStudentProfileComponent],
  templateUrl: './edit-profile.component.html',
  standalone: true
})
export class EditProfileComponent {
  accountType = localStorage.getItem('pfe_match_user_type');
}
