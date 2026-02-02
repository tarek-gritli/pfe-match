import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { CardComponent, CardContentComponent, CardHeaderComponent, CardTitleComponent } from '../../Common/card/card.component';
import { ButtonComponent } from '../../Common/button/button.component';
import { BadgeComponent } from '../../Common/badge/badge.component';
import { AvatarComponent } from '../../Common/avatar/avatar.component';
import { Company } from '../../../models/company-profile.model';
import { CompanyService} from '../../../services/company.service';
import { inject } from '@angular/core';

interface Pfe {
  id: string;
  enterpriseId: string;
  status: 'open' | 'closed';
}

@Component({
  selector: 'app-company-profile',
  standalone: true,
  imports: [
    CommonModule,
    CardComponent,
    CardContentComponent,
    CardHeaderComponent,
    CardTitleComponent,
    ButtonComponent,
    BadgeComponent,
    AvatarComponent
  ],
  templateUrl: './company-profile.component.html',
  styleUrls: ['./company-profile.component.css']
})
export class CompanyProfileComponent implements OnInit {
  private companyService = inject(CompanyService);
  currentEnterprise: Company = {
    name: '',
    industry: '',
    location: '',
    size: '',
    technologies: [],
    contactEmail: '',
  };

  enterprisePfes: Pfe[] = [];
  openPfes: Pfe[] = [];
  isLoading = true;

  constructor(private router: Router) {}

  ngOnInit(): void {
    this.companyService.getProfile().subscribe({
      next: (company) => {
        this.currentEnterprise = company;
      },
      error: () => {
        this.isLoading = false;
      }
    })
  }

  loadEnterpriseData(): void {
    // TODO: Replace with actual service call
    this.currentEnterprise = {
      name: 'TechCorp Solutions',
      logo: 'https://github.com/shadcn.png',
      industry: 'Software Development',
      location: 'Tunis, Tunisia',
      size: '50-200 employees',
      description: 'We build cutting-edge software solutions tailored to the needs of modern businesses. Passionate about innovation and technology-driven growth.',
      foundedYear: 2018,
      technologies: ['Angular', 'React', 'Node.js', 'PostgreSQL', 'AWS', 'Docker'],
      website: 'https://techcorp.com',
      linkedinUrl: 'https://linkedin.com/company/techcorp',
      contactEmail: 'contact@techcorp.com'
    };
  }

  loadPfes(): void {
    // TODO: Replace with actual service call
    const allPfes: Pfe[] = [
      { id: '1', enterpriseId: 'techcorp-1', status: 'open' },
      { id: '2', enterpriseId: 'techcorp-1', status: 'open' },
      { id: '3', enterpriseId: 'techcorp-1', status: 'closed' },
      { id: '4', enterpriseId: 'techcorp-1', status: 'open' }
    ];

    this.enterprisePfes = allPfes;
    this.openPfes = allPfes.filter(pfe => pfe.status === 'open');
  }

  getInitials(name: string): string {
    return name
      .split(' ')
      .slice(0, 2)
      .map(n => n[0])
      .join('')
      .toUpperCase();
  }

  navigateToEdit(): void {
    this.router.navigate(['/profile/edit']);
  }

  navigateToManagePfes(): void {
    this.router.navigate(['/']);
  }

  getMailtoLink(): string {
    return 'mailto:' + this.currentEnterprise.contactEmail;
  }
}