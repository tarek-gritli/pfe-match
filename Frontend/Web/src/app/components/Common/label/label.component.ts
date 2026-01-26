import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-label',
  standalone: true,
  imports: [CommonModule],
  template: `
    <label class="label" [attr.for]="htmlFor">
      <ng-content></ng-content>
    </label>
  `,
  styleUrls: ['./label.component.css']
})
export class LabelComponent {
  @Input() htmlFor?: string;
}