import { Component, ViewChild, ViewContainerRef, OnInit } from '@angular/core';

@Component({
  selector: 'app-create-profile',
  template: `
    @if (isLoading) {
      <div>Loading...</div>
    }
    <div #profileContainer></div>
  `,
  standalone: true
})
export class CreateProfileComponent implements OnInit {
  @ViewChild('profileContainer', { read: ViewContainerRef, static: true }) 
  container!: ViewContainerRef;
  
  accountType = localStorage.getItem('pfe_match_user_type');
  isLoading = true;

  async ngOnInit() {
    try {
      if (this.accountType === 'student') {
        const { CreateStudentProfileComponent } = await import('../student/create-student-profile/create-student-profile.component');
        this.container.createComponent(CreateStudentProfileComponent);
      } else {
        const { CreateCompanyProfileComponent } = await import('../company/create-company-profile/create-company-profile.component');
        this.container.createComponent(CreateCompanyProfileComponent);
      }
    } catch (error) {
      console.error('Failed to load create profile component:', error);
    } finally {
      this.isLoading = false;
    }
  }
}