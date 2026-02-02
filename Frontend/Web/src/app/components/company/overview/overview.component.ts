import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { PfeFormDialogComponent } from '../pfe-form-dialog/pfe-form-dialog.component';
import {PFEService} from '../../../services/pfe.service';

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
  companyName = 'TechVision AI';
  companyDescription = 'Artificial Intelligence';
  companyLogo = 'assets/company-logo.png';

  // Statistics
  activePFEs = 2;
  totalApplicants = 1;
  topApplicants = 1;
  avgMatchRate = 78;

  // PFE Listings
  pfeListings: PFEListing[] = [
    {
      id: '1',
      title: 'AI-Powered Image Recognition System',
      status: 'open',
      category: 'Artificial Intelligence',
      duration: '6 months',
      skills: ['Python', 'TensorFlow', 'Computer Vision', 'Deep Learning'],
      applicantCount: 1
    },
    {
      id: '2',
      title: 'NLP Chatbot for Customer Support',
      status: 'open',
      category: 'Artificial Intelligence',
      duration: '4 months',
      skills: ['Python', 'NLP', 'Machine Learning', 'API Development'],
      applicantCount: 0
    }
  ];

  // Recent Applicants
  recentApplicants: Applicant[] = [
    {
      id: '1',
      name: 'Marie Dupont',
      initials: 'M',
      appliedTo: 'AI-Powered Image Recognition System',
      matchRate: 92,
      avatarColor: '#6366F1'
    }
  ];

  constructor(
    private dialog: MatDialog,
    private router: Router,
    private pfeService: PFEService
  ) {}

  ngOnInit(): void {
    // Initialize component
  }

  navigateToListing(listingId: string): void {
    console.log('Navigate to listing:', listingId);
    // Navigate to applicants page filtered by this PFE
    this.router.navigate(['//companies/applicants'], {
      queryParams: { pfeId: listingId }
    });
  }

  navigateToApplicant(applicantId: string): void {
    console.log('Navigate to applicant:', applicantId);
    // Implement navigation logic
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
        this.pfeService.createPFE(result).subscribe({
          next: (newPFE) => {
            console.log('PFE created:', newPFE);
            // Rafraîchir la liste
          },
          error: (err) => console.error('Error:', err)
        });

        // For now, just add it to the list (in real app, refresh from API)
        const newpfe: PFEListing = {
          id: (this.pfeListings.length + 1).toString(),
          ...result
        };
        this.pfeListings.unshift(newpfe);
        this.activePFEs++;
      }
    });
  }
}
