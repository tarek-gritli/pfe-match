import { Routes } from '@angular/router';
import { StudentProfileComponent } from './components/student/student-profile/student-profile.component';
import { CreateStudentProfileComponent } from './components/student/create-student-profile/create-student-profile.component';
import { EditStudentProfileComponent } from './components/student/edit-student-profile/edit-student-profile.component';
import { RegisterComponent } from './auth/pages/register/register.component';
import { LoginComponent } from './auth/pages/login/login.component';
import { OverviewComponent } from './components/company/overview/overview.component';
import { ApplicantsComponent } from './components/company/applicants/applicants.component';

export const routes: Routes = [
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: 'register', component: RegisterComponent },
  { path: 'login', component: LoginComponent },

  // student
  { path: 'profile', component: StudentProfileComponent },
  { path: 'create-profile', component: CreateStudentProfileComponent },
  { path: 'edit-profile', component: EditStudentProfileComponent },

  // Enterprise routes (placeholder for now)
  { path: 'enterprise/create-profile', component: OverviewComponent }, // TODO: Create EnterpriseProfileComponent
  { path: 'companies/overview-pfe', component: OverviewComponent },
  { path: 'companies/applicants', component: ApplicantsComponent }
];
