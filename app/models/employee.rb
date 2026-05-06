# frozen_string_literal: true

class Employee < ApplicationRecord
  # Validations
  validates :full_name, :job_title, :country, :salary, :phone, presence: true
  validates :salary, numericality: { greater_than: 0 }
  validates :email, uniqueness: true, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :email?
  validates :phone, format: { with: /\A\d{10}\z/ }

  private

  def email?
    email.present?
  end
end
