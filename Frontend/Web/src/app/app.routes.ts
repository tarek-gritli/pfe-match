import { Routes } from '@angular/router';
import { StudentProfileComponent } from './components/student/student-profile/student-profile.component';
import { CreateStudentProfileComponent } from './components/student/create-student-profile/create-student-profile.component';

export const routes: Routes = [
  { path: 'profile', component: StudentProfileComponent },
  { path: 'create-profile', component: CreateStudentProfileComponent }
];