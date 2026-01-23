import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

export type AvatarSize = 'sm' | 'default' | 'lg' | 'xl';

@Component({
  selector: 'app-avatar',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './avatar.component.html',
  styleUrls: ['./avatar.component.css']
})
export class AvatarComponent {
  @Input() src: string = '';
  @Input() alt: string = '';
  @Input() fallback: string = '';
  @Input() size: AvatarSize = 'default';
  
  imageLoaded: boolean = false;
  imageError: boolean = false;

  onImageLoad(): void {
    this.imageLoaded = true;
    this.imageError = false;
  }

  onImageError(): void {
    this.imageError = true;
    this.imageLoaded = false;
  }

  get showFallback(): boolean {
    return !this.src || this.imageError || !this.imageLoaded;
  }

  get avatarClasses(): string {
    return `avatar-root avatar-${this.size}`;
  }
}