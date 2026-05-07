# Salary Management Tool

A full-stack salary management application for HR managers to manage 10,000+ employees.

## Tech Stack
- **Backend**: Ruby on Rails 7.0 (API mode)
- **Frontend**: React 18 + Tailwind CSS
- **Database**: SQLite
- **Testing**: RSpec, FactoryBot, Shoulda Matchers

## Features
- **Employee CRUD**: Add, view, update, delete employees
- **Salary Insights**: Min/max/avg salary by country, by job title
- **Dashboard**: Total payroll, top paying countries, salary distribution

## Setup

### Backend
```bash
bundle install
rails db:create db:migrate
rails db:seed  # Seeds 10,000 employees (~1.3 seconds)
rails server   # Runs on http://localhost:3000
```

### Frontend
```bash
cd frontend
npm install
npm start      # Runs on http://localhost:3001
```

## API Endpoints

### Employees
- `GET /employees` - List all employees
- `POST /employees` - Create employee
- `PUT /employees/:id` - Update employee
- `DELETE /employees/:id` - Delete employee

### Salary Insights
- `GET /api/v1/salary_insights/summary` - Overall stats
- `GET /api/v1/salary_insights/by_country?country=India` - Stats by country
- `GET /api/v1/salary_insights/by_job_title?job_title=...&country=...` - Stats by job title
- `GET /api/v1/salary_insights/countries` - List countries
- `GET /api/v1/salary_insights/job_titles` - List job titles

## Testing
```bash
bundle exec rspec  # 51 examples, 0 failures
```

## Seed Performance
- 10,000 employees seeded in ~1.3 seconds
- Uses `insert_all` for bulk insert
- Batch processing (1000 per batch)
