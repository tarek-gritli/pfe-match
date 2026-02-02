import { Component, inject, signal, computed, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { rxResource } from '@angular/core/rxjs-interop';
import { PFEService } from '../../../services/pfe.service';
import { StudentApplication } from '../../../common/interfaces/interface';

@Component({
  selector: 'app-my-applications',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './my-applications.component.html',
  styleUrls: ['./my-applications.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MyApplicationsComponent {
  private pfeService = inject(PFEService);

  private applicationsResource = rxResource({
    loader: () => this.pfeService.getMyApplications()
  });

  applications = computed(() => this.applicationsResource.value() ?? []);
  loading = this.applicationsResource.isLoading;
  error = computed(() => {
    const err = this.applicationsResource.error();
    return err ? (err as Error).message || 'Failed to load applications' : null;
  });

  selectedApplication = signal<StudentApplication | null>(null);
  showDetailModal = signal(false);

  hasApplications = computed(() => this.applications().length > 0);

  getMatchScoreColor(score: number): string {
    if (score >= 70) return '#22c55e';
    if (score >= 50) return '#f59e0b';
    return '#ef4444';
  }

  getMatchScoreLabel(score: number): string {
    if (score >= 70) return 'Great Match';
    if (score >= 50) return 'Good Match';
    return 'Low Match';
  }

  getStatusClass(status: string): string {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'status-accepted';
      case 'rejected':
        return 'status-rejected';
      case 'interview':
        return 'status-interview';
      case 'reviewed':
        return 'status-reviewed';
      default:
        return 'status-pending';
    }
  }

  formatDate(dateString: string): string {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  }

  openDetail(application: StudentApplication): void {
    this.selectedApplication.set(application);
    this.showDetailModal.set(true);
  }

  closeDetail(): void {
    this.showDetailModal.set(false);
    this.selectedApplication.set(null);
  }

  refresh(): void {
    this.applicationsResource.reload();
  }

  getCompanyLogo(application: StudentApplication): string {
    const logo = application.pfe_listing?.company?.logoUrl;
    const companyName = application.pfe_listing?.company?.name || 'C';
    return logo || `https://ui-avatars.com/api/?name=${encodeURIComponent(companyName)}&background=3b82f6&color=fff`;
  }
}
