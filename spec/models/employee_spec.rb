require 'rails_helper'

RSpec.describe Employee, type: :model do
  subject do
    described_class.new(
      full_name: "Test User",
      job_title: "ROR Engineer",
      country: "India",
      salary: 50000,
      email: "test@example.com",
      phone: "9876543210"
    )
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is invalid without full_name' do
      subject.full_name = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid without job_title' do
      subject.job_title = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid without country' do
      subject.country = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid without salary' do
      subject.salary = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid without phone' do
      subject.phone = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid with negative salary' do
      subject.salary = -100
      expect(subject).not_to be_valid
    end
  end
end