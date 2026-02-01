/**
 * SuccessAlertComponent
 * 
 * Displays success messages in a styled alert box.
 * Used in authentication forms to show successful operations.
 * 
 * Features:
 * - Success icon prefix
 * - Success/positive styling
 * - Conditionally rendered based on message presence
 */
import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
    selector: 'app-success-alert',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './success-alert.component.html',
    styleUrls: ['./success-alert.component.css']
})
export class SuccessAlertComponent {
    /** The success message to display */
    @Input() message: string = '';
}
