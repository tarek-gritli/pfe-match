import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-card-container',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './card-container.component.html',
  styleUrls: ['./card-container.component.css']
})
export class CardContainerComponent {
  @Input() title?: string;
  @Input() icon?: string;
  @Input() noPadding = false;
  @Input() border = false;
  @Input() borderColor?: string;
  @Input() gradient = false;
}