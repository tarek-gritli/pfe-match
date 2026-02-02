import { Component } from '@angular/core';
import { StudentProfileComponent } from '../student/student-profile/student-profile.component';
import { CompanyProfileComponent } from '../company/company-profile/company-profile.component';


@Component({
  selector: 'app-profile',
  imports: [StudentProfileComponent, CompanyProfileComponent],
  templateUrl: './profile.component.html',
  standalone: true
})
export class ProfileComponent {
  accountType = localStorage.getItem('pfe_match_user_type');
}
