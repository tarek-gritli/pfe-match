import { Routes } from '@angular/router';
import { ProfileComponent } from './Student/profile/profile.component';
import { EditProfileComponent } from './Student/edit-profile/edit-profile.component';
import { CreateProfileComponent } from './Student/create-profile/create-profile.component';

export const routes: Routes = [
  { path: 'profile', component: ProfileComponent },
  { path: 'edit-profile', component: EditProfileComponent },
  { path: 'create-profile', component: CreateProfileComponent }
];