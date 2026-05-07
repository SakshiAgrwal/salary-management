# frozen_string_literal: true

module Api
  module V1
    class SalaryInsightsController < ApplicationController
      def by_country
        country = params[:country]
        return render json: { error: 'Country parameter is required' }, status: :bad_request if country.blank?

        employees = Employee.where(country: country)
        return render json: { error: "No employees found in #{country}" }, status: :not_found if employees.empty?

        render json: {
          country: country,
          employee_count: employees.count,
          min_salary: employees.minimum(:salary).to_f,
          max_salary: employees.maximum(:salary).to_f,
          avg_salary: employees.average(:salary).to_f.round(2),
          median_salary: median(employees.pluck(:salary)),
          total_payroll: employees.sum(:salary).to_f
        }
      end

      def by_job_title
        job_title = params[:job_title]
        country = params[:country]
        return render json: { error: 'Job title parameter is required' }, status: :bad_request if job_title.blank?

        employees = Employee.where(job_title: job_title)
        employees = employees.where(country: country) if country.present?

        if employees.empty?
          return render json: { error: "No #{job_title} found" }, status: :not_found
        end

        render json: {
          job_title: job_title,
          country: country || 'All Countries',
          employee_count: employees.count,
          min_salary: employees.minimum(:salary).to_f,
          max_salary: employees.maximum(:salary).to_f,
          avg_salary: employees.average(:salary).to_f.round(2),
          median_salary: median(employees.pluck(:salary))
        }
      end

      def summary
        render json: {
          total_employees: Employee.count,
          total_payroll: Employee.sum(:salary).to_f,
          overall_avg_salary: Employee.average(:salary).to_f.round(2),
          overall_min_salary: Employee.minimum(:salary).to_f,
          overall_max_salary: Employee.maximum(:salary).to_f,
          countries_count: Employee.distinct.count(:country),
          job_titles_count: Employee.distinct.count(:job_title),
          salary_by_country: salary_by_country,
          top_paying_countries: top_paying_countries,
          salary_distribution: salary_distribution
        }
      end

      def countries
        render json: Employee.distinct.pluck(:country).sort
      end

      def job_titles
        render json: Employee.distinct.pluck(:job_title).sort
      end

      private

      def median(values)
        return 0 if values.empty?

        sorted = values.map(&:to_f).sort
        mid = sorted.length / 2
        sorted.length.odd? ? sorted[mid] : ((sorted[mid - 1] + sorted[mid]) / 2.0).round(2)
      end

      def salary_by_country
        Employee.group(:country).select('country, COUNT(*) as employee_count, AVG(salary) as avg_salary')
                .map { |r| { country: r.country, employee_count: r.employee_count, avg_salary: r.avg_salary.to_f.round(2) } }
      end

      def top_paying_countries
        Employee.group(:country).average(:salary).sort_by { |_, v| -v }.first(5)
                .map { |c, a| { country: c, avg_salary: a.to_f.round(2) } }
      end

      def salary_distribution
        [
          { range: '< 50K', count: Employee.where(salary: 0...50_000).count },
          { range: '50K - 100K', count: Employee.where(salary: 50_000...100_000).count },
          { range: '100K - 150K', count: Employee.where(salary: 100_000...150_000).count },
          { range: '150K - 200K', count: Employee.where(salary: 150_000...200_000).count },
          { range: '> 200K', count: Employee.where(salary: 200_000..).count }
        ]
      end
    end
  end
end