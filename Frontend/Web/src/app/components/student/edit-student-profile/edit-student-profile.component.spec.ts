import { ComponentFixture, TestBed } from '@angular/core/testing';

import { EditStudentProfileComponent } from './edit-student-profile.component';

describe('EditStudentProfileComponent', () => {
  let component: EditStudentProfileComponent;
  let fixture: ComponentFixture<EditStudentProfileComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [EditStudentProfileComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(EditStudentProfileComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
