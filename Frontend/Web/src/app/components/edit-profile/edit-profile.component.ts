import { Component, ViewChild, ViewContainerRef, OnInit } from '@angular/core';

@Component({
  selector: 'app-edit-profile',
  template: `
    @if (isLoading) {
      <div>Loading...</div>
    }
    <div #profileContainer></div>
  `,
  standalone: true
})
export class EditProfileComponent implements OnInit {
  @ViewChild('profileContainer', { read: ViewContainerRef, static: true }) 
  container!: ViewContainerRef;
  
  accountType = localStorage.getItem('pfe_match_user_type');
  isLoading = true;

  async ngOnInit() {
    try {
      if (this.accountType === 'student') {
        const { EditStudentProfileComponent } = await import('../student/edit-student-profile/edit-student-profile.component');
        this.container.createComponent(EditStudentProfileComponent);
      } else {
        const { EditCompanyProfileComponent } = await import('../company/edit-company-profile/edit-company-profile.component');
        this.container.createComponent(EditCompanyProfileComponent);
      }
    } catch (error) {
      console.error('Failed to load edit profile component:', error);
    } finally {
      this.isLoading = false;
    }
  }
}