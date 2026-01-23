import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-progress',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './progress.component.html',
  styleUrls: ['./progress.component.css']
})
export class ProgressComponent {
  @Input() value: number = 0;
  @Input() max: number = 100;

  get progressPercentage(): number {
    if (this.max <= 0) return 0;
    const percentage = (this.value / this.max) * 100;
    return Math.min(Math.max(percentage, 0), 100);
  }

  get indicatorStyle(): string {
    return `translateX(-${100 - this.progressPercentage}%)`;
  }
}