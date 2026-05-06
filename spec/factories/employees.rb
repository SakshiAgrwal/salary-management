# frozen_string_literal: true

FactoryBot.define do
  factory :employee do
    full_name { Faker::Name.name }
    job_title { Faker::Job.title }
    country { Faker::Address.country }
    salary { Faker::Number.between(from: 10_000, to: 500_000).to_d }
    email { Faker::Internet.unique.email }
    phone { Faker::Number.number(digits: 10).to_s }

    # Traits for different scenarios
    trait :without_email do
      email { nil }
    end

    trait :with_invalid_email do
      email { 'not-an-email' }
    end

    trait :with_invalid_phone do
      phone { '12345' }
    end

    trait :with_zero_salary do
      salary { 0 }
    end

    trait :with_negative_salary do
      salary { -50_000 }
    end

    trait :with_high_salary do
      salary { 10_000_000 }
    end

    trait :senior_engineer do
      job_title { 'Senior Software Engineer' }
      salary { Faker::Number.between(from: 150_000, to: 300_000).to_d }
    end

    trait :intern do
      job_title { 'Intern' }
      salary { Faker::Number.between(from: 15_000, to: 30_000).to_d }
    end

    # Edge case traits for data quality
    trait :with_whitespace_name do
      full_name { '   ' }
    end

    trait :with_special_characters_name do
      full_name { "O'Brien-Smith Jr." }
    end

    trait :with_unicode_name do
      full_name { 'José García' }
    end

    trait :with_long_name do
      full_name { Faker::Lorem.characters(number: 255) }
    end
  end
end
