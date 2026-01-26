import { Routes } from '@angular/router';
import { StudentProfileComponent } from './components/student/student-profile/student-profile.component';
import { CreateStudentProfileComponent } from './components/student/create-student-profile/create-student-profile.component';
import { EditStudentProfileComponent } from './components/student/edit-student-profile/edit-student-profile.component';

export const routes: Routes = [
  { path: 'profile', component: StudentProfileComponent },
  { path: 'create-profile', component: CreateStudentProfileComponent },
  { path: 'edit-profile', component: EditStudentProfileComponent }
];