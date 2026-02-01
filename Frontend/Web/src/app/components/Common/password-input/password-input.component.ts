/**
 * PasswordInputComponent
 * 
 * NEW COMPONENT: Created to eliminate repetitive password input + toggle button patterns
 * found across Login and Register components.
 * 
 * Features:
 * - Show/hide password toggle with emoji icons
 * - Implements ControlValueAccessor for seamless reactive forms integration
 * - Accessible with proper ARIA labels
 * - Reusable across any form requiring password input
 */
import { Component, Input, forwardRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';

@Component({
    selector: 'app-password-input',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './password-input.component.html',
    styleUrls: ['./password-input.component.css'],
    providers: [
        {
            provide: NG_VALUE_ACCESSOR,
            useExisting: forwardRef(() => PasswordInputComponent),
            multi: true
        }
    ]
})
export class PasswordInputComponent implements ControlValueAccessor {
    /** Input field ID for label association */
    @Input() inputId: string = '';

    /** Placeholder text */
    @Input() placeholder: string = 'Enter your password';

    /** Autocomplete attribute for browser autofill */
    @Input() autocomplete: string = 'current-password';

    /** Controls password visibility */
    showPassword = false;

    /** Internal value storage */
    value: string = '';

    /** Disabled state */
    disabled = false;

    /** ControlValueAccessor callbacks */
    onChange: (value: string) => void = () => { };
    onTouched: () => void = () => { };

    /** Toggle password visibility */
    toggleVisibility(): void {
        this.showPassword = !this.showPassword;
    }

    /** Handle input changes */
    onInput(event: Event): void {
        const input = event.target as HTMLInputElement;
        this.value = input.value;
        this.onChange(this.value);
    }

    // ControlValueAccessor implementation
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
