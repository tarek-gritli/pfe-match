import { Component, input, output, signal, computed, inject, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { PFEListing, MatchResult } from '../../../common/interfaces/interface';
import { PFEService } from '../../../services/pfe.service';

@Component({
  selector: 'app-pfe-detail-modal',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './pfe-detail-modal.component.html',
  styleUrls: ['./pfe-detail-modal.component.css'],
})
export class PfeDetailModalComponent {
  private pfeService = inject(PFEService);

  offer = input.required<PFEListing | null>();
  isOpen = input(false);

  close = output<void>();
  applied = output<void>();

  loading = signal(false);
  matchPreview = signal<MatchResult | null>(null);
  matchLoading = signal(false);
  applySuccess = signal(false);
  applyError = signal<string | null>(null);

  companyLogo = computed(() => {
    const offerValue = this.offer();
    if (!offerValue) return '';
    const logo = offerValue.company?.logoUrl;
    const companyName = offerValue.company?.name || 'C';
    return (
      logo ||
      `https://ui-avatars.com/api/?name=${encodeURIComponent(companyName)}&background=3b82f6&color=fff`
    );
  });

  matchScoreColor = computed(() => {
    const score = this.matchPreview()?.match_score ?? 0;
    if (score >= 70) return '#22c55e'; // green
    if (score >= 50) return '#f59e0b'; // amber
    return '#ef4444'; // red
  });

  matchScoreLabel = computed(() => {
    const score = this.matchPreview()?.match_score ?? 0;
    if (score >= 70) return 'Great Match!';
    if (score >= 50) return 'Good Match';
    return 'Low Match';
  });

  constructor() {
    // Load match preview when modal opens with an offer
    effect(() => {
      const offerValue = this.offer();
      const isOpenValue = this.isOpen();
      
      if (isOpenValue && offerValue && !this.matchPreview()) {
        this.loadMatchPreview(offerValue.id);
      }
    });
  }

  loadMatchPreview(pfeId: string): void {
    this.matchLoading.set(true);
    this.pfeService.getMatchPreview(pfeId).subscribe({
      next: (result) => {
        this.matchPreview.set(result);
        this.matchLoading.set(false);
      },
      error: (err) => {
        console.error('Failed to load match preview:', err);
        this.matchLoading.set(false);
      }
    });
  }

  applyToOffer(): void {
    const offerValue = this.offer();
    if (!offerValue) return;

    this.loading.set(true);
    this.applyError.set(null);

    this.pfeService.applyToPFE(offerValue.id).subscribe({
      next: () => {
        this.loading.set(false);
        this.applySuccess.set(true);
        this.applied.emit();
      },
      error: (err) => {
        this.loading.set(false);
        this.applyError.set(err.message || 'Failed to apply. Please try again.');
      }
    });
  }

  onClose(): void {
    this.matchPreview.set(null);
    this.applySuccess.set(false);
    this.applyError.set(null);
    this.close.emit();
  }

  onBackdropClick(event: MouseEvent): void {
    if ((event.target as HTMLElement).classList.contains('modal-backdrop')) {
      this.onClose();
    }
  }
}
