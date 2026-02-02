import {
  Component,
  computed,
  signal,
  ChangeDetectionStrategy,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { PfeCardComponent } from '../pfe-card/pfe-card.component';
import { PFEListing } from '../../../common/interfaces/interface';

@Component({
  selector: 'app-explore',
  standalone: true,
  imports: [CommonModule, FormsModule, PfeCardComponent],
  templateUrl: './explore.component.html',
  styleUrls: ['./explore.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ExploreComponent {
  private allOffers = signal<PFEListing[]>([
    {
      id: '1',
      title: 'Full-Stack Web Development with React & Node.js',
      status: 'open',
      description:
        'Join our dynamic team to build modern web applications using cutting-edge technologies. You will work on real-world projects involving React, Node.js, and MongoDB, gaining hands-on experience in full-stack development.',
      duration: '6 months',
      category: 'Web Development',
      applicantCount: 8,
      location: 'Tunis, Tunisia',
      company: {
        id: '1',
        name: 'TechCorp Tunisia',
        industry: 'Information Technology',
      },
      skills: ['JavaScript', 'React', 'Communication', 'Problem Solving'],
    },
    {
      id: '2',
      title: 'Mobile App Development - Flutter & Firebase',
      description:
        'Design and develop cross-platform mobile applications using Flutter framework. Work with Firebase for backend services and gain experience in mobile UI/UX design principles.',
      duration: '5 months',
      category: 'Mobile Development',
      location: 'Sfax, Tunisia',
      status: 'closed',
      company: {
        id: '2',
        name: 'Mobile Solutions Inc',
        industry: 'Mobile Apps',
      },
      skills: ['Dart', 'Flutter', 'UI/UX Design', 'Mobile Development'],
      applicantCount: 5,
    },
  ]).asReadonly();

  searchInput = signal('');
  favorites = signal(new Set<string>());
  loading = signal(false);
  error = signal<string | null>(null);

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
    // TODO: Navigate to offer details page
    console.log('Clicked offer:', offer);
  }

  refreshOffers(): void {
    console.log('Mock data is static, no refresh needed');
  }
}
