/**
 * GoogleButtonComponent
 * 
 * NEW COMPONENT: Reusable Google OAuth button with loading state.
 * Used in both Login and Register pages for "Sign in/up with Google".
 * 
 * Features:
 * - Official Google branding and icon
 * - Loading spinner state
 * - Accessible with proper ARIA attributes
 * - Configurable button text
 */
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
    selector: 'app-google-button',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './google-button.component.html',
    styleUrls: ['./google-button.component.css']
})
export class GoogleButtonComponent {
    /** Button text (e.g., "Continue with Google", "Sign up with Google") */
    @Input() text: string = 'Continue with Google';

    /** Loading state - shows spinner when true */
    @Input() isLoading: boolean = false;

    /** Disabled state */
    @Input() disabled: boolean = false;

    /** Emitted when button is clicked */
    @Output() googleClick = new EventEmitter<void>();

    onClick(): void {
        if (!this.isLoading && !this.disabled) {
            this.googleClick.emit();
        }
    }
}
