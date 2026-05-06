class Employee < ApplicationRecord
  validates :full_name, :job_title, :country, :salary, :phone, presence: true
  validates :salary, numericality: { greater_than: 0 }
  validates :email, uniqueness: true, allow_nil: true
  validates :phone, format: { with: /\A\d{10}\z/, message: "must be 10 digits" }
end