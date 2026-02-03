import { Routes } from '@angular/router';
import { StudentProfileComponent } from './components/student/student-profile/student-profile.component';
import { CreateStudentProfileComponent } from './components/student/create-student-profile/create-student-profile.component';
import { EditStudentProfileComponent } from './components/student/edit-student-profile/edit-student-profile.component';
import { ExploreComponent } from './components/student/explore/explore.component';
import { MyApplicationsComponent } from './components/student/my-applications/my-applications.component';
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
import { authGuard } from './auth/guards/auth.guard';
import { guestGuard } from './auth/guards/guest.guard';
import { enterpriseGuard } from './auth/guards/enterprise.guard';
import { studentGuard } from './auth/guards/student.guard';

export const routes: Routes = [
  { path: '', redirectTo: '/login', pathMatch: 'full' },

  { path: 'register', component: RegisterComponent, canActivate: [guestGuard] },
  { path: 'login', component: LoginComponent, canActivate: [guestGuard] },

  { path: 'profile', component: ProfileComponent, canActivate: [authGuard] },
  { path: 'create-profile', component: CreateProfileComponent, canActivate: [authGuard] },
  { path: 'edit-profile', component: EditProfileComponent, canActivate: [authGuard] },
  { path: 'explore', component: ExploreComponent, canActivate: [studentGuard] },
  { path: 'my-applications', component: MyApplicationsComponent, canActivate: [studentGuard] },

  { path: 'enterprise/dashboard', component: StudentProfileComponent, canActivate: [authGuard] }, // TODO: Create EnterpriseDashboardComponent
  { path: 'companies/overview-pfe', component: OverviewComponent, canActivate: [enterpriseGuard] },
  { path: 'companies/applicants', component: ApplicantsComponent, canActivate: [enterpriseGuard] }
];

