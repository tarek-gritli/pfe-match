/**
 * LoadingButtonComponent
 * 
 * NEW COMPONENT: Button with integrated loading spinner state.
 * Extends the existing ButtonComponent concept with loading functionality.
 * Used for form submissions where async operations occur.
 * 
 * Features:
 * - Loading spinner replaces button text when loading
 * - Disabled during loading to prevent double-submit
 * - Configurable variants matching existing button system
 */
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

export type LoadingButtonVariant = 'primary' | 'secondary' | 'outline' | 'gradient';

@Component({
    selector: 'app-loading-button',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './loading-button.component.html',
    styleUrls: ['./loading-button.component.css']
})
export class LoadingButtonComponent {
    /** Button text when not loading */
    @Input() text: string = 'Submit';

    /** Whether the button is in loading state */
    @Input() isLoading: boolean = false;

    /** Button type attribute */
    @Input() type: 'button' | 'submit' | 'reset' = 'button';

    /** Button variant for styling */
    @Input() variant: LoadingButtonVariant = 'primary';

    /** Additional disabled state (beyond loading) */
    @Input() disabled: boolean = false;

    /** Emitted when button is clicked */
    @Output() buttonClick = new EventEmitter<void>();

    get buttonClasses(): string {
        return `loading-button loading-button-${this.variant}`;
    }

    onClick(): void {
        if (!this.isLoading && !this.disabled) {
            this.buttonClick.emit();
        }
    }
}
