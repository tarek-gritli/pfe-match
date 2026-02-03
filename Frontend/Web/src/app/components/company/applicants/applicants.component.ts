import { Component, OnInit, signal, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { toSignal } from '@angular/core/rxjs-interop';
import { ApplicantService, ApplicantWithStatus } from '../../../services/applicant.service';
import { PFEService } from '../../../services/pfe.service';
import { CompanyService } from '../../../services/company.service';

@Component({
  selector: 'app-applicants',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './applicants.component.html',
  styleUrls: ['./applicants.component.css']
})
export class ApplicantsComponent implements OnInit {
  // Injection des services
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private applicantService = inject(ApplicantService);
  private pfeService = inject(PFEService);
  private companyService = inject(CompanyService);

  // ============================================
  // Signals pour l'état
  // ============================================

  companyName = signal('');
  companyDescription = signal('');

  // État de chargement
  isLoading = signal(false);
  error = signal<string | null>(null);

  // Filtre sélectionné
  selectedPfeId = signal<string>('all');

  // ============================================
  // Convertir Observables en Signals
  // ============================================

  // Récupérer les PFE listings
  pfeListings = toSignal(this.pfeService.pfeListings$, {
    initialValue: []
  });

  // Récupérer tous les applicants
  allApplicants = toSignal(this.applicantService.applicants$, {
    initialValue: [] as ApplicantWithStatus[]
  });

  // ============================================
  // Computed Signals (filtrage automatique)
  // ============================================

  /**
   * Applicants filtrés selon le PFE sélectionné
   * Se recalcule AUTOMATIQUEMENT quand selectedPfeId ou allApplicants change
   */
  filteredApplicants = computed(() => {
    const filter = this.selectedPfeId();
    const applicants = this.allApplicants();

    if (filter === 'all') {
      return applicants;
    }

    // Use loose equality to handle string/number type mismatch
    return applicants.filter(app => String(app.pfeId) === String(filter));
  });

  /**
   * Nombre total d'applicants filtrés
   */
  totalApplicants = computed(() => {
    return this.filteredApplicants().length;
  });

  /**
   * Taux de match moyen
   */
  averageMatchRate = computed(() => {
    const applicants = this.filteredApplicants();
    if (applicants.length === 0) return 0;

    const sum = applicants.reduce((acc, app) => acc + app.matchRate, 0);
    return Math.round(sum / applicants.length);
  });

  /**
   * Nombre d'applicants en attente de review
   */
  pendingReviews = computed(() => {
    return this.filteredApplicants().filter(
      app => app.status === 'pending'
    ).length;
  });

  /**
   * Nombre d'applicants shortlisted
   */
  shortlisted = computed(() => {
    return this.filteredApplicants().filter(
      app => app.status === 'shortlisted' || app.status === 'interview'
    ).length;
  });

  // ============================================
  // Lifecycle
  // ============================================

  ngOnInit(): void {
    // Charger les données initiales
    this.loadData();

    // Charger le profil de l'entreprise
    this.companyService.getProfile().subscribe({
      next: (profile: any) => {
        this.companyName.set(profile.name || profile.company_name || '');
        this.companyDescription.set(profile.industry || '');
      },
      error: (err) => console.error('Error loading company profile:', err)
    });

    // Écouter les query params pour le filtre
    this.route.queryParams.subscribe(params => {
      if (params['pfeId']) {
        this.selectedPfeId.set(params['pfeId']);
      }
    });
  }

  // ============================================
  // Méthodes
  // ============================================

  /**
   * Charger toutes les données
   */
  loadData(): void {
    this.isLoading.set(true);
    this.error.set(null);

    // Charger les PFE listings
    this.pfeService.getPFEListings().subscribe({
      error: (err) => {
        console.error('Error loading PFE listings:', err);
        this.loadFallbackPFEData();
      }
    });

    // Charger les applicants
    this.applicantService.getAllApplicants().subscribe({
      next: () => {
        console.log('Applicants loaded');
        this.isLoading.set(false);
      },
      error: (err) => {
        console.error('Error loading applicants:', err);
        this.error.set('Failed to load applicants. Using cached data.');
        this.isLoading.set(false);
        this.loadFallbackApplicantsData();
      }
    });
  }

  /**
   * Données de secours pour PFE
   */
  private loadFallbackPFEData(): void {
    console.log('Using fallback PFE data');
    // Les données seront chargées depuis le cache du service
  }

  /**
   * Données de secours pour applicants
   */
  private loadFallbackApplicantsData(): void {
    console.log('Using fallback applicants data');
    // Les données seront chargées depuis le cache du service
  }

  /**
   * Changer le filtre PFE
   * Le filtrage se fait AUTOMATIQUEMENT via computed signal
   */
  onPfeFilterChange(): void {
    // Le computed signal 'filteredApplicants' se recalculera automatiquement
    console.log('Filter changed to:', this.selectedPfeId());
  }

  /**
   * Voir les détails d'un applicant
   */
  viewApplicantDetails(applicantId: string): void {
    console.log('View applicant details:', applicantId);
    // this.router.navigate(['/applicants', applicantId]);
  }

  /**
   * Mettre à jour le statut d'un applicant
   */
  updateApplicantStatus(
    applicantId: string,
    newStatus: ApplicantWithStatus['status']
  ): void {
    this.applicantService.updateApplicantStatus(applicantId, newStatus).subscribe({
      next: (updated) => {
        console.log('Applicant status updated:', updated);
        // Le cache sera automatiquement mis à jour par le service
      },
      error: (err) => {
        console.error('Error updating status:', err);
        this.error.set('Failed to update applicant status');
      }
    });
  }

  /**
   * Obtenir la classe CSS pour un statut
   */
  getStatusClass(status: string): string {
    const statusClasses: { [key: string]: string } = {
      'pending': 'status-pending',
      'reviewed': 'status-reviewed',
      'shortlisted': 'status-shortlisted',
      'interview': 'status-interview',
      'accepted': 'status-accepted',
      'rejected': 'status-rejected'
    };
    return statusClasses[status] || 'status-pending';
  }

  /**
   * Obtenir le label pour un statut
   */
  getStatusLabel(status: string): string {
    const statusLabels: { [key: string]: string } = {
      'pending': 'Pending Review',
      'reviewed': 'Reviewed',
      'shortlisted': 'Shortlisted',
      'interview': 'Interview',
      'accepted': 'Accepted',
      'rejected': 'Rejected'
    };
    return statusLabels[status] || status;
  }

  /**
   * Formater une date
   */
  formatDate(date: Date): string {
    return new Intl.DateTimeFormat('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric'
    }).format(new Date(date));
  }

  /**
   * Retour à la page overview
   */
  goBack(): void {
    this.router.navigate(['/overview']);
  }

  /**
   * Rafraîchir les données
   */
  refresh(): void {
    this.loadData();
  }
}
