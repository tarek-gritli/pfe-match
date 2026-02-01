import { Component, OnInit, Inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, FormArray } from '@angular/forms';
import { MatDialogRef, MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatSelectModule } from '@angular/material/select';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { PFEListing } from '../../../common/interfaces/interface';

@Component({
  selector: 'app-pfe-form-dialog',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatSelectModule,
    MatChipsModule,
    MatIconModule
  ],
  templateUrl: './pfe-form-dialog.component.html',
  styleUrls: ['./pfe-form-dialog.component.css']
})
export class PfeFormDialogComponent implements OnInit {
  pfeForm!: FormGroup;
  isEditMode = false;

  // Available options
  categories = [
    'Artificial Intelligence',
    'Web Development',
    'Mobile Development',
    'Data Science',
    'Cybersecurity',
    'Cloud Computing',
    'DevOps',
    'Blockchain',
    'IoT',
    'Game Development'
  ];

  durations = [
    '2 months',
    '3 months',
    '4 months',
    '5 months',
    '6 months'
  ];

  availableSkills = [
    'Python',
    'JavaScript',
    'TypeScript',
    'Java',
    'C++',
    'React',
    'Angular',
    'Vue.js',
    'Node.js',
    'Django',
    'Flask',
    'Spring Boot',
    'TensorFlow',
    'PyTorch',
    'Machine Learning',
    'Deep Learning',
    'NLP',
    'Computer Vision',
    'SQL',
    'MongoDB',
    'PostgreSQL',
    'Docker',
    'Kubernetes',
    'AWS',
    'Azure',
    'GCP',
    'Git',
    'REST API',
    'GraphQL',
    'Microservices'
  ];

  selectedSkills: string[] = [];

  constructor(
    private fb: FormBuilder,
    public dialogRef: MatDialogRef<PfeFormDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: { pfe?: PFEListing }
  ) {
    this.isEditMode = !!data?.pfe;
  }

  ngOnInit(): void {
    this.initForm();

    if (this.isEditMode && this.data.pfe) {
      this.populateForm(this.data.pfe);
    }
  }

  initForm(): void {
    this.pfeForm = this.fb.group({
      title: ['', [Validators.required, Validators.maxLength(100)]],
      category: ['', [Validators.required, Validators.maxLength(50)]],
      duration: ['', Validators.required],
      description: ['', [Validators.required, Validators.maxLength(1000)]],
      department: ['', Validators.maxLength(50)],
      status: ['open', Validators.required]
    });
  }

  populateForm(pfe: PFEListing): void {
    this.pfeForm.patchValue({
      title: pfe.title,
      category: pfe.category,
      duration: pfe.duration,
      description: pfe.description || '',
      department: pfe.department || '',
      status: pfe.status
    });
    this.selectedSkills = [...pfe.skills];
  }

  addSkill(skill: string): void {
    if (skill && !this.selectedSkills.includes(skill)) {
      if (this.selectedSkills.length < 10) {
        this.selectedSkills.push(skill);
      }
    }
  }

  removeSkill(skill: string): void {
    const index = this.selectedSkills.indexOf(skill);
    if (index >= 0) {
      this.selectedSkills.splice(index, 1);
    }
  }

  onSubmit(): void {
    if (this.pfeForm.valid && this.selectedSkills.length > 0) {
      const formValue = {
        ...this.pfeForm.value,
        skills: this.selectedSkills,
        applicantCount: this.data?.pfe?.applicantCount || 0
      };

      this.dialogRef.close(formValue);
    } else {
      // Mark all fields as touched to show validation errors
      Object.keys(this.pfeForm.controls).forEach(key => {
        this.pfeForm.get(key)?.markAsTouched();
      });
    }
  }

  onCancel(): void {
    this.dialogRef.close();
  }

  // Helper methods for template
  get titleControl() {
    return this.pfeForm.get('title');
  }

  get categoryControl() {
    return this.pfeForm.get('category');
  }

  get durationControl() {
    return this.pfeForm.get('duration');
  }

  get descriptionControl() {
    return this.pfeForm.get('description');
  }

  get departmentControl() {
    return this.pfeForm.get('department');
  }
}
