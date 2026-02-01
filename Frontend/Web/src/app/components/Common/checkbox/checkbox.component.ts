import { Component, Input, forwardRef } from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';

@Component({
  selector: 'app-checkbox',
  standalone: true,
  imports: [],
  template: `
    <button
      type="button"
      role="checkbox"
      [attr.aria-checked]="checked"
      [disabled]="disabled"
      [class]="getCheckboxClasses()"
      (click)="toggle()"
      (keydown.space)="$event.preventDefault(); toggle()"
    >
      @if (checked) {
        <span class="checkbox-indicator">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="16"
            height="16"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="checkbox-icon"
          >
            <path d="M20 6 9 17l-5-5"/>
          </svg>
        </span>
      }
    </button>
  `,
  styleUrls: ['./checkbox.component.css'],
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => CheckboxComponent),
      multi: true
    }
  ]
})
export class CheckboxComponent implements ControlValueAccessor {
  @Input() disabled: boolean = false;
  @Input() className: string = '';

  checked: boolean = false;
  onChange: (value: boolean) => void = () => {};
  onTouched: () => void = () => {};

  toggle(): void {
    if (this.disabled) return;
    
    this.checked = !this.checked;
    this.onChange(this.checked);
    this.onTouched();
  }

  getCheckboxClasses(): string {
    const baseClasses = 'checkbox';
    const stateClasses = this.checked ? 'checkbox-checked' : '';
    return `${baseClasses} ${stateClasses} ${this.className}`.trim();
  }

  // ControlValueAccessor implementation
  writeValue(value: boolean): void {
    this.checked = value || false;
  }

  registerOnChange(fn: (value: boolean) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: () => void): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.disabled = isDisabled;
  }
}