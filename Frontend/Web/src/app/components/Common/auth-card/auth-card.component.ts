import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
    selector: 'app-auth-card',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './auth-card.component.html',
    styleUrls: ['./auth-card.component.css']
})
export class AuthCardComponent {
    @Input() title: string = 'PFE Match';
    @Input() subtitle: string = '';
    @Input() maxWidth: string = '420px';
}
