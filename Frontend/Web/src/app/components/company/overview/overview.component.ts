import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { PfeFormDialogComponent } from '../pfe-form-dialog/pfe-form-dialog.component';
import { PFEService } from '../../../services/pfe.service';
import { ApplicantService } from '../../../services/applicant.service';
import { CompanyService } from '../../../services/company.service';

interface PFEListing {
  id: string;
  title: string;
  status: 'open' | 'closed';
  category: string;
  duration: string;
  skills: string[];
  applicantCount: number;
}

interface Applicant {
  id: string;
  name: string;
  initials: string;
  appliedTo: string;
  matchRate: number;
  avatarColor: string;
}

@Component({
  selector: 'app-overview',
  standalone: true,
  imports: [CommonModule, MatDialogModule],
  templateUrl: './overview.component.html',
  styleUrls: ['./overview.component.css']
})
export class OverviewComponent implements OnInit {
  companyName = '';
  companyDescription = '';
  companyLogo = '';

  // Statistics (initialized to defaults, populated from backend)
  activePFEs = 0;
  totalApplicants = 0;
  topApplicants = 0;
  avgMatchRate = 0;

  // PFE Listings - start empty and load from backend
  pfeListings: PFEListing[] = [];

  // Recent Applicants - will be populated from backend
  recentApplicants: Applicant[] = [];

  constructor(
    private dialog: MatDialog,
    private router: Router,
    private pfeService: PFEService,
    private applicantService: ApplicantService,
    private companyService: CompanyService
  ) {}

  ngOnInit(): void {
    // Load company profile
    this.companyService.getProfile().subscribe({
      next: (profile: any) => {
        this.companyName = profile.name || profile.company_name || '';
        this.companyDescription = profile.industry || '';
        if (profile.logo || profile.company_logo) {
          const logoPath = (profile.logo || profile.company_logo).replace(/\\/g, '/');
          this.companyLogo = this.companyService.getProfileImageUrl(logoPath);
        }
      },
      error: (err) => {
        console.error('Failed to load company profile:', err);
      }
    });

    // Load listings and statistics from backend
    this.pfeService.getPFEListings().subscribe({
      next: (listings) => {
        this.pfeListings = listings;
      },
      error: (err) => {
        console.error('Failed to load PFE listings:', err);
      }
    });

    this.pfeService.getStatistics().subscribe({
      next: (stats) => {
        this.activePFEs = stats.activePFEs;
        this.totalApplicants = stats.totalApplicants;
        this.topApplicants = stats.topApplicants;
        this.avgMatchRate = stats.avgMatchRate;
      },
      error: (err) => console.error('Failed to load dashboard statistics:', err)
    });

    // Load recent applicants (take latest 5)
    this.applicantService.getAllApplicants().subscribe({
      next: (apps) => {
        // Sort by applicationDate descending and take first 5
        const sorted = apps.slice().sort((a, b) => new Date(b.applicationDate).getTime() - new Date(a.applicationDate).getTime());
        this.recentApplicants = sorted.slice(0, 5).map(a => ({
          id: a.id,
          name: a.name,
          initials: a.initials || (a.name ? a.name.split(' ')[0][0].toUpperCase() : ''),
          appliedTo: a.appliedTo || '',
          matchRate: a.matchRate,
          avatarColor: a.avatarColor || '#6366F1'
        }));
      },
      error: (err) => console.error('Failed to load applicants:', err)
    });
  }

  navigateToListing(listingId: string): void {
    console.log('Navigate to listing:', listingId);
    // Navigate to applicants page filtered by this PFE
    this.router.navigate(['/companies/applicants'], {
      queryParams: { pfeId: listingId }
    });
  }

  navigateToApplicant(applicantId: string): void {
    console.log('Navigate to applicant:', applicantId);
    // Implement navigation logic - assume route exists
    this.router.navigate(['/companies/applicants', applicantId]);
  }

  postNewPFE(): void {
    const dialogRef = this.dialog.open(PfeFormDialogComponent, {
      width: '700px',
      maxWidth: '90vw',
      maxHeight: '90vh',
      data: {}
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        console.log('New PFE created:', result);
        // Use backend to create PFE and update cache/list
        this.pfeService.createPFE(result).subscribe({
          next: (newPFE) => {
            console.log('PFE created:', newPFE);
            // refresh local list (service already updates cache)
            // but also ensure local view is in sync
            this.pfeListings.unshift(newPFE);
            this.activePFEs++;
          },
          error: (err) => console.error('Error:', err)
        });
      }
    });
  }
}
