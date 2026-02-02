import { Component, input, output, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PFEListing } from '../../../common/interfaces/interface';
import { BadgeComponent } from '../../Common/badge/badge.component';

@Component({
  selector: 'app-pfe-card',
  standalone: true,
  imports: [CommonModule, BadgeComponent],
  templateUrl: './pfe-card.component.html',
  styleUrls: ['./pfe-card.component.css'],
})
export class PfeCardComponent {
  offer = input.required<PFEListing>();
  isFavorite = input(false);

  favoriteToggle = output<string>();
  cardClick = output<PFEListing>();

  onFavoriteClick(event: Event): void {
    event.stopPropagation(); // Prevent card click
    this.favoriteToggle.emit(this.offer().id);
  }

  onCardClick(): void {
    this.cardClick.emit(this.offer());
  }

  truncatedDescription = computed(() => {
    const maxLength = 120;
    const description = this.offer().description || '';
    if (description.length <= maxLength) {
      return description;
    }
    return description.substring(0, maxLength).trim() + '...';
  });

  companyLogo = computed(() => {
    const logo = this.offer().company?.logoUrl;
    const companyName = this.offer().company?.name || 'C';
    return (
      logo ||
      `https://ui-avatars.com/api/?name=${encodeURIComponent(companyName)}&background=3b82f6&color=fff`
    );
  });
}
