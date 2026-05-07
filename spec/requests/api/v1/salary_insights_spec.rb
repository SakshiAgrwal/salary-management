# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::SalaryInsights' do
  describe 'GET /api/v1/salary_insights/by_country' do
    let!(:india_employees) do
      [
        create(:employee, country: 'India', salary: 50_000),
        create(:employee, country: 'India', salary: 100_000),
        create(:employee, country: 'India', salary: 150_000)
      ]
    end
    let!(:usa_employee) { create(:employee, country: 'United States', salary: 200_000) }

    context 'with valid country parameter' do
      it 'returns salary statistics for the country' do
        get '/api/v1/salary_insights/by_country', params: { country: 'India' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['country']).to eq('India')
        expect(json['employee_count']).to eq(3)
        expect(json['min_salary']).to eq(50_000.0)
        expect(json['max_salary']).to eq(150_000.0)
        expect(json['avg_salary']).to eq(100_000.0)
        expect(json['median_salary']).to eq(100_000.0)
        expect(json['total_payroll']).to eq(300_000.0)
      end
    end

    context 'without country parameter' do
      it 'returns bad request error' do
        get '/api/v1/salary_insights/by_country'

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Country parameter is required')
      end
    end

    context 'with non-existent country' do
      it 'returns not found error' do
        get '/api/v1/salary_insights/by_country', params: { country: 'Atlantis' }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to include('No employees found')
      end
    end
  end

  describe 'GET /api/v1/salary_insights/by_job_title' do
    let!(:engineers) do
      [
        create(:employee, job_title: 'Software Engineer', country: 'India', salary: 80_000),
        create(:employee, job_title: 'Software Engineer', country: 'India', salary: 120_000),
        create(:employee, job_title: 'Software Engineer', country: 'United States', salary: 150_000)
      ]
    end
    let!(:manager) { create(:employee, job_title: 'Engineering Manager', country: 'India', salary: 200_000) }

    context 'with job_title only' do
      it 'returns salary statistics for all countries' do
        get '/api/v1/salary_insights/by_job_title', params: { job_title: 'Software Engineer' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['job_title']).to eq('Software Engineer')
        expect(json['country']).to eq('All Countries')
        expect(json['employee_count']).to eq(3)
        expect(json['min_salary']).to eq(80_000.0)
        expect(json['max_salary']).to eq(150_000.0)
      end
    end

    context 'with job_title and country' do
      it 'returns salary statistics for specific country' do
        get '/api/v1/salary_insights/by_job_title', params: { job_title: 'Software Engineer', country: 'India' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['job_title']).to eq('Software Engineer')
        expect(json['country']).to eq('India')
        expect(json['employee_count']).to eq(2)
        expect(json['avg_salary']).to eq(100_000.0)
      end
    end

    context 'without job_title parameter' do
      it 'returns bad request error' do
        get '/api/v1/salary_insights/by_job_title'

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Job title parameter is required')
      end
    end
  end

  describe 'GET /api/v1/salary_insights/summary' do
    before do
      create(:employee, country: 'India', job_title: 'Software Engineer', salary: 90_000)
      create(:employee, country: 'India', job_title: 'Software Engineer', salary: 110_000)
      create(:employee, country: 'India', job_title: 'Data Scientist', salary: 140_000)
      create(:employee, country: 'India', job_title: 'Engineering Manager', salary: 160_000)
      create(:employee, country: 'United States', job_title: 'Software Engineer', salary: 150_000)
      create(:employee, country: 'United States', job_title: 'Principal Engineer', salary: 220_000)
      create(:employee, country: 'United States', job_title: 'Engineering Manager', salary: 180_000)
    end

    it 'returns overall salary summary' do
      get '/api/v1/salary_insights/summary'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['total_employees']).to eq(7)
      expect(json['total_payroll']).to eq(1_050_000.0)
      expect(json['countries_count']).to eq(2)
      expect(json['job_titles_count']).to eq(4)
      expect(json['salary_by_country']).to be_an(Array)
      expect(json['top_paying_countries']).to be_an(Array)
      expect(json['salary_distribution']).to be_an(Array)
      expect(json['overall_median_salary']).to eq(150_000.0)
      expect(json['top_roles_by_country']).to be_an(Array)
    end

    it 'includes salary distribution ranges' do
      get '/api/v1/salary_insights/summary'

      json = JSON.parse(response.body)
      distribution = json['salary_distribution']

      expect(distribution.map { |d| d['range'] }).to include('100K - 150K', '150K - 200K')
    end

    it 'includes top 5 highest paid roles per country sorted by average salary' do
      get '/api/v1/salary_insights/summary'

      json = JSON.parse(response.body)
      top_roles = json['top_roles_by_country']

      india_roles = top_roles.find { |entry| entry['country'] == 'India' }['roles']
      us_roles = top_roles.find { |entry| entry['country'] == 'United States' }['roles']

      expect(india_roles.first['job_title']).to eq('Engineering Manager')
      expect(india_roles.first['avg_salary']).to eq(160_000.0)
      expect(us_roles.first['job_title']).to eq('Principal Engineer')
      expect(us_roles.first['avg_salary']).to eq(220_000.0)
      expect(us_roles.size).to be <= 5
    end
  end

  describe 'GET /api/v1/salary_insights/countries' do
    before do
      create(:employee, country: 'India')
      create(:employee, country: 'United States')
      create(:employee, country: 'Germany')
      create(:employee, country: 'India') # duplicate
    end

    it 'returns unique sorted list of countries' do
      get '/api/v1/salary_insights/countries'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json).to eq(['Germany', 'India', 'United States'])
    end
  end

  describe 'GET /api/v1/salary_insights/job_titles' do
    before do
      create(:employee, job_title: 'Software Engineer')
      create(:employee, job_title: 'Data Scientist')
      create(:employee, job_title: 'Software Engineer') # duplicate
    end

    it 'returns unique sorted list of job titles' do
      get '/api/v1/salary_insights/job_titles'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json).to eq(['Data Scientist', 'Software Engineer'])
    end
  end
end
