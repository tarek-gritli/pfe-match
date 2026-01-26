import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CreateStudentProfileComponent } from './create-student-profile.component';

describe('CreateStudentProfileComponent', () => {
  let component: CreateStudentProfileComponent;
  let fixture: ComponentFixture<CreateStudentProfileComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CreateStudentProfileComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(CreateStudentProfileComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
