import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-separator',
  standalone: true,
  imports: [],
  template: `
    <div
      [attr.role]="decorative ? 'none' : 'separator'"
      [attr.aria-orientation]="!decorative ? orientation : null"
      [class]="getSeparatorClasses()"
    ></div>
  `,
  styleUrls: ['./separator.component.css']
})
export class SeparatorComponent {
  @Input() orientation: 'horizontal' | 'vertical' = 'horizontal';
  @Input() decorative: boolean = true;
  @Input() className: string = '';

  getSeparatorClasses(): string {
    const baseClasses = 'separator';
    const orientationClass = this.orientation === 'horizontal' 
      ? 'separator-horizontal' 
      : 'separator-vertical';
    return `${baseClasses} ${orientationClass} ${this.className}`.trim();
  }
}