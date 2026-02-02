import { Component, ViewChild, ViewContainerRef, OnInit } from '@angular/core';

@Component({
  selector: 'app-profile',
  template: `
    @if (isLoading) {
      <div>Loading profile...</div>
    }
    <div #profileContainer></div>
  `,
  standalone: true
})
export class ProfileComponent implements OnInit {
  @ViewChild('profileContainer', { read: ViewContainerRef, static: true }) 
  container!: ViewContainerRef;
  
  accountType = localStorage.getItem('pfe_match_user_type');
  isLoading = true;

  async ngOnInit() {
    try {
      if (this.accountType === 'student') {
        const { StudentProfileComponent } = await import('../student/student-profile/student-profile.component');
        this.container.createComponent(StudentProfileComponent);
      } else {
        const { CompanyProfileComponent } = await import('../company/company-profile/company-profile.component');
        this.container.createComponent(CompanyProfileComponent);
      }
    } catch (error) {
      console.error('Failed to load profile component:', error);
    } finally {
      this.isLoading = false;
    }
  }
}