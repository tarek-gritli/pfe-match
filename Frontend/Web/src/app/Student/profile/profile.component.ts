import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { CardContainerComponent } from '../../components/card-container/card-container.component';

interface Skill {
  name: string;
}

interface Tool {
  name: string;
}

@Component({
  selector: 'app-student-profile',
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.css'],
  standalone: true,
  imports: [CardContainerComponent]
})
export class ProfileComponent {
  profileIntegrity = 85;
  
  skills: Skill[] = [
    { name: 'TypeScript' },
    { name: 'Python' },
    { name: 'React & Next.js' },
    { name: 'PostgreSQL' },
    { name: 'Docker' },
    { name: 'Kubernetes' }
  ];

  tools: Tool[] = [
    { name: 'AWS (EC2, S3)' },
    { name: 'Git / GitHub' },
    { name: 'Jira / Agile' },
    { name: 'GraphQL' },
    { name: 'Terraform' }
  ];

  profileData = {
    name: 'Alexandre Dubois',
    title: 'SOFTWARE ENGINEERING SENIOR',
    university: 'Tech University of Munich',
    location: 'Munich, Germany',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC9D10QIt--py9-2R8pwT23fv-vWtFNzrVh-kZJFJsHE_npBGu18o9oBWQvctbFyVw9lsR3tbetRjXrkd-ScYW1dh06x3up4q8Tu5SmP3lDHz6hbLFdyIBKIQaH10jvtA_TGZIEzFUSqLXr5HIuFBX0afO07jkASUTUtH9ewSg-e1MzrXzzaeU-CHQJA1yCJF_r0VA40SuqAVnophnJSndNjMFrnb5S2u5okgemJV5vH9_oVkMawZtOWHt47VBOEaxmp1LEdabs-94',
    summary: 'Passionate software engineering student specializing in cloud-native applications and AI integration. I focus on building scalable backend architectures using Node.js and Python. Looking for a 6-month PFE opportunity starting February 2024 to tackle complex distributed systems challenges.',
    resume: {
      filename: 'Resume_Alexandre_D.pdf',
      lastUpdated: 'Oct 24, 2023',
      size: '1.2 MB'
    }
  };

  constructor(private router: Router) {}

  navigateToEditProfile(): void {
    this.router.navigate(['/edit-profile']);
  }

  downloadResume(): void {
    console.log('Download resume');
  }
}