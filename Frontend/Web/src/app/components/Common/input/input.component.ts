import { Component, Input, forwardRef, ContentChild, TemplateRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';

@Component({
  selector: 'app-input',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="input-wrapper">
      <!-- Left Icon -->
      <span *ngIf="hasLeftIcon" class="input-icon input-icon-left">
        <ng-content select="[leftIcon]"></ng-content>
      </span>
      
      <!-- Input Field -->
      <input
        class="input"
        [class.input-with-icon-left]="hasLeftIcon && !hasRightIcon"
        [class.input-with-icon-right]="!hasLeftIcon && hasRightIcon"
        [class.input-with-icons]="hasLeftIcon && hasRightIcon"
        [type]="type"
        [placeholder]="placeholder"
        [disabled]="disabled"
        [value]="value"
        (input)="onInput($event)"
        (blur)="onTouched()"
      />
      
      <!-- Right Icon -->
      <span *ngIf="hasRightIcon" class="input-icon input-icon-right">
        <ng-content select="[rightIcon]"></ng-content>
      </span>
    </div>
  `,
  styleUrls: ['./input.component.css'],
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => InputComponent),
      multi: true
    }
  ]
})
export class InputComponent implements ControlValueAccessor {
  @Input() type: string = 'text';
  @Input() placeholder: string = '';
  @Input() disabled: boolean = false;
  @Input() hasLeftIcon: boolean = false;
  @Input() hasRightIcon: boolean = false;

  value: string = '';
  onChange: (value: string) => void = () => {};
  onTouched: () => void = () => {};

  onInput(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.value = input.value;
    this.onChange(this.value);
  }

  writeValue(value: string): void {
    this.value = value || '';
  }

  registerOnChange(fn: (value: string) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: () => void): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.disabled = isDisabled;
  }
}