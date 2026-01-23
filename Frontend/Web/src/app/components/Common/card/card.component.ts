import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-card',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="card">
      <ng-content></ng-content>
    </div>
  `,
  styleUrls: ['./card.component.css']
})
export class CardComponent {}

@Component({
  selector: 'app-card-header',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="card-header">
      <ng-content></ng-content>
    </div>
  `,
  styleUrls: ['./card.component.css']
})
export class CardHeaderComponent {}

@Component({
  selector: 'app-card-title',
  standalone: true,
  imports: [CommonModule],
  template: `
    <h3 class="card-title">
      <ng-content></ng-content>
    </h3>
  `,
  styleUrls: ['./card.component.css']
})
export class CardTitleComponent {}

@Component({
  selector: 'app-card-description',
  standalone: true,
  imports: [CommonModule],
  template: `
    <p class="card-description">
      <ng-content></ng-content>
    </p>
  `,
  styleUrls: ['./card.component.css']
})
export class CardDescriptionComponent {}

@Component({
  selector: 'app-card-content',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="card-content">
      <ng-content></ng-content>
    </div>
  `,
  styleUrls: ['./card.component.css']
})
export class CardContentComponent {}

@Component({
  selector: 'app-card-footer',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="card-footer">
      <ng-content></ng-content>
    </div>
  `,
  styleUrls: ['./card.component.css']
})
export class CardFooterComponent {}