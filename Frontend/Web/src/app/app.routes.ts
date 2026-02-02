import { Routes } from '@angular/router';
import { StudentProfileComponent } from './components/student/student-profile/student-profile.component';
import { CreateStudentProfileComponent } from './components/student/create-student-profile/create-student-profile.component';
import { EditStudentProfileComponent } from './components/student/edit-student-profile/edit-student-profile.component';
import { RegisterComponent } from './auth/pages/register/register.component';
import { LoginComponent } from './auth/pages/login/login.component';
import {OverviewComponent} from './components/company/overview/overview.component';
import {ApplicantsComponent} from './components/company/applicants/applicants.component';
import { CompanyProfileComponent } from './components/company/company-profile/company-profile.component';
import { EditCompanyProfileComponent } from './components/company/edit-company-profile/edit-company-profile.component';
import { CreateCompanyProfileComponent } from './components/company/create-company-profile/create-company-profile.component';
import { ProfileComponent } from './components/profile/profile.component';
import { CreateProfileComponent } from './components/create-profile/create-profile.component';
import { EditProfileComponent } from './components/edit-profile/edit-profile.component';

export const routes: Routes = [
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: 'profile', component: ProfileComponent },
  { path: 'create-profile', component: CreateProfileComponent },
  { path: 'edit-profile', component: EditProfileComponent },
  { path: 'register', component: RegisterComponent },
  { path: 'login', component: LoginComponent },
  // Enterprise routes (placeholder for now)
  { path: 'enterprise/dashboard', component: StudentProfileComponent }, // TODO: Create EnterpriseDashboardComponent
];
  //{path: 'login', component: LoginComponent },
  //{path: 'companies/overview-pfe', component: OverviewComponent},
  //{path: 'companies/applicants', component: ApplicantsComponent}
//];
