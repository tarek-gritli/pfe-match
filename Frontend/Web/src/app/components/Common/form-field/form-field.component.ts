/**
 * FormFieldComponent
 * 
 * NEW COMPONENT: Wraps the common pattern of label + input + error message.
 * Reduces repetitive markup in forms and ensures consistent styling.
 * 
 * Usage:
 * <app-form-field label="Email" [errorMessage]="getEmailError()">
 *   <input formControlName="email" />
 * </app-form-field>
 */
import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
    selector: 'app-form-field',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './form-field.component.html',
    styleUrls: ['./form-field.component.css']
})
export class FormFieldComponent {
    /** Label text displayed above the input */
    @Input() label: string = '';

    /** HTML 'for' attribute to associate label with input */
    @Input() htmlFor: string = '';

    /** Error message to display below input (shown when truthy) */
    @Input() errorMessage: string = '';

    /** Whether to show the error state */
    @Input() showError: boolean = false;
}
