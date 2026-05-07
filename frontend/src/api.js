import axios from 'axios';

const BACKEND_URL = process.env.REACT_APP_API_BASE || '';
const API_BASE = `${BACKEND_URL}/api/v1`;
const EMPLOYEES_BASE = `${BACKEND_URL}/employees`;

export const api = {
  // Employees CRUD
  getEmployees: (params = {}) => axios.get(EMPLOYEES_BASE, { params }),
  getEmployee: (id) => axios.get(`${EMPLOYEES_BASE}/${id}`),
  createEmployee: (data) => axios.post(EMPLOYEES_BASE, { employee: data }),
  updateEmployee: (id, data) => axios.put(`${EMPLOYEES_BASE}/${id}`, { employee: data }),
  deleteEmployee: (id) => axios.delete(`${EMPLOYEES_BASE}/${id}`),

  // Salary Insights
  getSummary: () => axios.get(`${API_BASE}/salary_insights/summary`),
  getByCountry: (country) => axios.get(`${API_BASE}/salary_insights/by_country`, { params: { country } }),
  getByJobTitle: (jobTitle, country) => axios.get(`${API_BASE}/salary_insights/by_job_title`, { params: { job_title: jobTitle, country } }),
  getCountries: () => axios.get(`${API_BASE}/salary_insights/countries`),
  getJobTitles: () => axios.get(`${API_BASE}/salary_insights/job_titles`),
};
