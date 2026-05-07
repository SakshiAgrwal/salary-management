# frozen_string_literal: true

Rails.application.routes.draw do
  resources :employees

  namespace :api do
    namespace :v1 do
      resources :salary_insights, only: [] do
        collection do
          get :by_country
          get :by_job_title
          get :summary
          get :countries
          get :job_titles
        end
      end
    end
  end
end
