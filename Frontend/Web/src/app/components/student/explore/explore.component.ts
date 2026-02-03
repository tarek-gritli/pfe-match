import {
  Component,
  computed,
  signal,
  inject,
} from '@angular/core';
import { rxResource } from '@angular/core/rxjs-interop';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { PfeCardComponent } from '../pfe-card/pfe-card.component';
import { PfeDetailModalComponent } from '../pfe-detail-modal/pfe-detail-modal.component';
import { PFEListing } from '../../../common/interfaces/interface';
import { ApiService } from '../../../api/api.service';
import { ENDPOINTS } from '../../../api/api.config';

@Component({
  selector: 'app-explore',
  standalone: true,
  imports: [CommonModule, FormsModule, PfeCardComponent, PfeDetailModalComponent],
  templateUrl: './explore.component.html',
  styleUrls: ['./explore.component.css'],
})
export class ExploreComponent {
  private api = inject(ApiService);

  private offersResource = rxResource({
    loader: () => this.api.get<PFEListing[]>(ENDPOINTS.PFE.EXPLORE)
  });

  // Get all offers from resource
  private allOffers = computed(() => this.offersResource.value() ?? []);

  // Loading and error states from resource
  loading = this.offersResource.isLoading;
  error = computed(() => typeof this.offersResource.error() === 'string' ? this.offersResource.error() : null);

  searchInput = signal('');
  favorites = signal(new Set<string>());
  
  // Modal state
  selectedOffer = signal<PFEListing | null>(null);
  isModalOpen = signal(false);

  offers = computed(() => {
    const query = this.searchInput().toLowerCase().trim();
    const allOffers = this.allOffers();

    if (!query) {
      return allOffers;
    }

    return allOffers.filter(
      (offer) =>
        offer.title.toLowerCase().includes(query) ||
        offer.company?.name?.toLowerCase().includes(query) ||
        offer.description?.toLowerCase().includes(query),
    );
  });

  hasOffers = computed(() => this.offers().length > 0);
  isEmpty = computed(() => this.offers().length === 0);

  resultCountText = computed(() => {
    const count = this.offers().length;
    const query = this.searchInput();

    if (query) {
      return `${count} result${count !== 1 ? 's' : ''} for "${query}"`;
    }
    return `${count} PFE offer${count !== 1 ? 's' : ''} available`;
  });

  onSearchInput(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.searchInput.set(input.value);
  }

  clearSearch(): void {
    this.searchInput.set('');
  }

  onFavoriteToggle(offerId: string): void {
    const currentFavorites = new Set(this.favorites());

    if (currentFavorites.has(offerId)) {
      currentFavorites.delete(offerId);
    } else {
      currentFavorites.add(offerId);
    }

    this.favorites.set(currentFavorites);
  }

  isFavorite(offerId: string): boolean {
    return this.favorites().has(offerId);
  }

  onCardClick(offer: PFEListing): void {
    this.selectedOffer.set(offer);
    this.isModalOpen.set(true);
  }

  closeModal(): void {
    this.isModalOpen.set(false);
    this.selectedOffer.set(null);
  }

  onApplied(): void {
    // Refresh offers to update applicant count
    this.refreshOffers();
  }

  refreshOffers(): void {
    this.offersResource.reload();
  }
}
