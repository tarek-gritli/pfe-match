/**
 * ErrorAlertComponent
 * 
 * NEW COMPONENT: Displays error messages in a styled alert box.
 * Used in authentication forms to show validation or API errors.
 * 
 * Features:
 * - Warning icon prefix
 * - Destructive/error styling
 * - Conditionally rendered based on message presence
 */
import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
    selector: 'app-error-alert',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './error-alert.component.html',
    styleUrls: ['./error-alert.component.css']
})
export class ErrorAlertComponent {
    /** The error message to display */
    @Input() message: string = '';
}
