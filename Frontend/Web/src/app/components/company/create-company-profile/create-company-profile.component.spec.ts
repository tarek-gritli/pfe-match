import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CreateCompanyProfileComponent } from './create-company-profile.component';

describe('CreateCompanyProfileComponent', () => {
  let component: CreateCompanyProfileComponent;
  let fixture: ComponentFixture<CreateCompanyProfileComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CreateCompanyProfileComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(CreateCompanyProfileComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
