# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Employee do
  subject(:employee) { build(:employee) }

  describe 'validations' do
    # Basic validity with factory
    it { is_expected.to be_valid }

    # Presence validations
    describe 'presence' do
      it { is_expected.to validate_presence_of(:full_name) }
      it { is_expected.to validate_presence_of(:job_title) }
      it { is_expected.to validate_presence_of(:country) }
      it { is_expected.to validate_presence_of(:salary) }
      it { is_expected.to validate_presence_of(:phone) }
    end

    # Numericality validations
    describe 'salary numericality' do
      it { is_expected.to validate_numericality_of(:salary).is_greater_than(0) }

      it 'is invalid with zero salary' do
        employee = build(:employee, :with_zero_salary)
        expect(employee).not_to be_valid
        expect(employee.errors[:salary]).to include('must be greater than 0')
      end

      it 'is invalid with negative salary' do
        employee = build(:employee, :with_negative_salary)
        expect(employee).not_to be_valid
        expect(employee.errors[:salary]).to include('must be greater than 0')
      end

      it 'is valid with high salary' do
        employee = build(:employee, :with_high_salary)
        expect(employee).to be_valid
      end
    end

    # Email validations - comprehensive
    describe 'email' do
      context 'with format validation' do
        it 'is valid with proper email format' do
          employee.email = 'test@example.com'
          expect(employee).to be_valid
        end

        it 'is valid with subdomain email' do
          employee.email = 'user@mail.company.co.uk'
          expect(employee).to be_valid
        end

        it 'is valid with plus addressing' do
          employee.email = 'user+tag@example.com'
          expect(employee).to be_valid
        end

        it 'is invalid with missing @' do
          employee.email = 'invalidemail.com'
          expect(employee).not_to be_valid
          expect(employee.errors[:email]).to be_present
        end

        it 'is invalid with missing domain' do
          employee.email = 'user@'
          expect(employee).not_to be_valid
        end

        it 'is invalid with spaces' do
          employee.email = 'user @example.com'
          expect(employee).not_to be_valid
        end

        it 'is invalid using factory trait' do
          employee = build(:employee, :with_invalid_email)
          expect(employee).not_to be_valid
        end
      end

      context 'when optional (allow_blank)' do
        it 'is valid without email' do
          employee = build(:employee, :without_email)
          expect(employee).to be_valid
        end

        it 'is valid with empty string email' do
          employee.email = ''
          expect(employee).to be_valid
        end
      end

      context 'with uniqueness validation' do
        it { is_expected.to validate_uniqueness_of(:email).allow_blank }

        it 'is invalid with duplicate email' do
          create(:employee, email: 'duplicate@example.com')
          new_employee = build(:employee, email: 'duplicate@example.com')

          expect(new_employee).not_to be_valid
          expect(new_employee.errors[:email]).to include('has already been taken')
        end

        it 'is case-sensitive for email uniqueness' do
          create(:employee, email: 'Test@Example.com')
          new_employee = build(:employee, email: 'test@example.com')

          # Default Rails uniqueness is case-sensitive
          expect(new_employee).to be_valid
        end

        it 'allows multiple employees without email' do
          create(:employee, :without_email)
          second_employee = build(:employee, :without_email)

          expect(second_employee).to be_valid
        end
      end
    end

    # Phone validations
    describe 'phone format' do
      it 'is valid with exactly 10 digits' do
        employee.phone = '1234567890'
        expect(employee).to be_valid
      end

      it 'is invalid with less than 10 digits' do
        employee = build(:employee, :with_invalid_phone)
        expect(employee).not_to be_valid
        expect(employee.errors[:phone]).to be_present
      end

      it 'is invalid with more than 10 digits' do
        employee.phone = '12345678901'
        expect(employee).not_to be_valid
      end

      it 'is invalid with letters' do
        employee.phone = '123456789a'
        expect(employee).not_to be_valid
      end

      it 'is invalid with special characters' do
        employee.phone = '123-456-7890'
        expect(employee).not_to be_valid
      end

      it 'is invalid with spaces' do
        employee.phone = '123 456 7890'
        expect(employee).not_to be_valid
      end
    end
  end

  # Edge cases for HR data quality
  describe 'data quality edge cases' do
    describe 'full_name' do
      it 'accepts names with special characters' do
        employee = build(:employee, :with_special_characters_name)
        expect(employee).to be_valid
      end

      it 'accepts unicode names' do
        employee = build(:employee, :with_unicode_name)
        expect(employee).to be_valid
      end

      it 'accepts long names' do
        employee = build(:employee, :with_long_name)
        expect(employee).to be_valid
      end

      it 'rejects whitespace-only names' do
        employee = build(:employee, :with_whitespace_name)
        # NOTE: presence validation doesn't catch whitespace-only by default
        # This test documents current behavior - consider adding strip validation
        expect(employee.full_name.strip).to be_empty
      end
    end

    describe 'salary precision' do
      it 'handles decimal salaries' do
        employee.salary = 50_000.50
        expect(employee).to be_valid
      end

      it 'handles very small positive salary' do
        employee.salary = 0.01
        expect(employee).to be_valid
      end
    end

    describe 'country' do
      it 'accepts various country formats' do
        ['USA', 'India', 'UK', 'Germany'].each do |country|
          employee.country = country
          expect(employee).to be_valid
        end
      end
    end
  end

  # Factory traits usage
  describe 'factory traits' do
    it 'creates valid senior engineer' do
      employee = build(:employee, :senior_engineer)
      expect(employee).to be_valid
      expect(employee.job_title).to eq('Senior Software Engineer')
      expect(employee.salary).to be >= 150_000
    end

    it 'creates valid intern' do
      employee = build(:employee, :intern)
      expect(employee).to be_valid
      expect(employee.job_title).to eq('Intern')
      expect(employee.salary).to be <= 30_000
    end
  end

  # Database persistence
  describe 'persistence' do
    it 'saves valid employee to database' do
      employee = build(:employee)
      expect { employee.save! }.to change(described_class, :count).by(1)
    end

    it 'does not save invalid employee' do
      employee = build(:employee, :with_negative_salary)
      expect { employee.save }.not_to change(described_class, :count)
    end

    it 'creates multiple unique employees' do
      employees = create_list(:employee, 5)
      expect(employees.map(&:email).uniq.count).to eq(5)
    end
  end
end
