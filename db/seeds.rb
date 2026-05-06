# frozen_string_literal: true

# Optimized seed script for 10,000 employees
# Performance considerations:
# - Bulk insert using insert_all (bypasses ActiveRecord callbacks for speed)
# - Pre-load name files into memory
# - Batch processing to manage memory
# - Disable logging during seed

require 'benchmark'

class EmployeeSeeder
  BATCH_SIZE = 1000
  TOTAL_EMPLOYEES = 10_000

  COUNTRIES = [
    'United States', 'India', 'United Kingdom', 'Germany', 'Canada',
    'Australia', 'France', 'Japan', 'Brazil', 'Netherlands'
  ].freeze

  JOB_TITLES = [
    'Software Engineer', 'Senior Software Engineer', 'Staff Engineer',
    'Engineering Manager', 'Product Manager', 'Senior Product Manager',
    'Data Scientist', 'Senior Data Scientist', 'Data Engineer',
    'DevOps Engineer', 'Senior DevOps Engineer', 'QA Engineer',
    'Senior QA Engineer', 'UX Designer', 'Senior UX Designer',
    'Technical Lead', 'Architect', 'Principal Engineer',
    'HR Manager', 'HR Specialist', 'Recruiter',
    'Finance Analyst', 'Accountant', 'Business Analyst'
  ].freeze

  # Salary ranges by job level (in USD)
  SALARY_RANGES = {
    'intern' => 30_000..50_000,
    'junior' => 50_000..80_000,
    'mid' => 80_000..120_000,
    'senior' => 120_000..180_000,
    'lead' => 150_000..220_000,
    'manager' => 130_000..200_000,
    'executive' => 200_000..350_000
  }.freeze

  def initialize
    @first_names = load_names('first_names.txt')
    @last_names = load_names('last_names.txt')
    puts "Loaded #{@first_names.size} first names and #{@last_names.size} last names"
  end

  def seed!
    puts "Seeding #{TOTAL_EMPLOYEES} employees..."

    # Clear existing data
    Employee.delete_all
    puts 'Cleared existing employees'

    time = Benchmark.measure do
      seed_in_batches
    end

    puts "Seeding completed in #{time.real.round(2)} seconds"
    puts "Total employees: #{Employee.count}"
  end

  private

  def load_names(filename)
    filepath = Rails.root.join('db', 'data', filename)
    File.readlines(filepath).map(&:strip).reject(&:empty?)
  end

  def seed_in_batches
    total_batches = (TOTAL_EMPLOYEES / BATCH_SIZE.to_f).ceil

    total_batches.times do |batch_num|
      batch_start = batch_num * BATCH_SIZE
      batch_end = [batch_start + BATCH_SIZE, TOTAL_EMPLOYEES].min
      batch_count = batch_end - batch_start

      employees = build_employee_batch(batch_count)

      # Use insert_all for bulk insert (much faster than create)
      Employee.insert_all(employees)

      print "\rBatch #{batch_num + 1}/#{total_batches} completed (#{batch_end} employees)"
    end
    puts # New line after progress
  end

  def build_employee_batch(count)
    now = Time.current

    Array.new(count) do
      job_title = JOB_TITLES.sample
      {
        full_name: generate_full_name,
        job_title: job_title,
        country: COUNTRIES.sample,
        salary: generate_salary(job_title),
        email: generate_unique_email,
        phone: generate_phone,
        created_at: now,
        updated_at: now
      }
    end
  end

  def generate_full_name
    "#{@first_names.sample} #{@last_names.sample}"
  end

  def generate_salary(job_title)
    level = determine_job_level(job_title)
    range = SALARY_RANGES[level]
    rand(range).round(-2) # Round to nearest 100
  end

  def determine_job_level(job_title)
    case job_title
    when /Principal|Architect/i then 'executive'
    when /Manager|Lead/i then 'manager'
    when /Senior|Staff/i then 'senior'
    when /Engineer|Designer|Analyst|Scientist/i then 'mid'
    else 'junior'
    end
  end

  def generate_unique_email
    # Use timestamp + random to ensure uniqueness
    timestamp = Time.current.to_f.to_s.delete('.')
    random = SecureRandom.hex(4)
    "employee_#{timestamp}_#{random}@company.com"
  end

  def generate_phone
    # Generate 10-digit phone number
    "#{rand(100..999)}#{rand(100..999)}#{rand(1000..9999)}"
  end
end

# Run the seeder
EmployeeSeeder.new.seed!
