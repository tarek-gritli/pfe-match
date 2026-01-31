/**
 * DividerComponent
 * 
 * NEW COMPONENT: Horizontal divider with optional centered text.
 * Commonly used in auth forms as "or" separator between form submit
 * and social login options.
 * 
 * Usage:
 * <app-divider text="or"></app-divider>
 */
import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
    selector: 'app-divider',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './divider.component.html',
    styleUrls: ['./divider.component.css']
})
export class DividerComponent {
    /** Optional text to display in the center of the divider */
    @Input() text: string = '';
}
