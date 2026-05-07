# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Employees API' do
  describe 'GET /employees' do
    let!(:india_engineer) { create(:employee, full_name: 'Alice Johnson', country: 'India', job_title: 'Software Engineer') }
    let!(:usa_manager) { create(:employee, full_name: 'Bob Smith', country: 'United States', job_title: 'Engineering Manager') }
    let!(:india_manager) { create(:employee, full_name: 'Carol Davis', country: 'India', job_title: 'Engineering Manager') }

    it 'returns paginated employees with metadata' do
      get '/employees', params: { page: 1, per_page: 2 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['data'].size).to eq(2)
      expect(json['meta']).to include(
        'total' => 3,
        'page' => 1,
        'per_page' => 2,
        'total_pages' => 2
      )
    end

    it 'filters by search query (full_name)' do
      get '/employees', params: { q: 'alice' }

      json = JSON.parse(response.body)
      names = json['data'].map { |emp| emp['full_name'] }

      expect(names).to contain_exactly('Alice Johnson')
      expect(json['meta']['total']).to eq(1)
    end

    it 'filters by country and job title' do
      get '/employees', params: { country: 'India', job_title: 'Engineering Manager' }

      json = JSON.parse(response.body)
      names = json['data'].map { |emp| emp['full_name'] }

      expect(names).to contain_exactly('Carol Davis')
      expect(json['meta']['total']).to eq(1)
    end
  end
end
