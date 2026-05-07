import React, { useState, useEffect } from 'react';
import { api } from './api';

function App() {
  const [view, setView] = useState('dashboard');
  const [employees, setEmployees] = useState([]);
  const [summary, setSummary] = useState(null);
  const [countries, setCountries] = useState([]);
  const [jobTitles, setJobTitles] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // Form state
  const [formData, setFormData] = useState({
    full_name: '', job_title: '', country: '', salary: '', email: '', phone: ''
  });
  const [editingId, setEditingId] = useState(null);

  // Filter state
  const [selectedCountry, setSelectedCountry] = useState('');
  const [selectedJobTitle, setSelectedJobTitle] = useState('');
  const [countryInsight, setCountryInsight] = useState(null);
  const [jobTitleInsight, setJobTitleInsight] = useState(null);

  useEffect(() => {
    loadInitialData();
  }, []);

  const loadInitialData = async () => {
    setLoading(true);
    try {
      const [empRes, sumRes, countryRes, jobRes] = await Promise.all([
        api.getEmployees(),
        api.getSummary(),
        api.getCountries(),
        api.getJobTitles()
      ]);
      setEmployees(empRes.data);
      setSummary(sumRes.data);
      setCountries(countryRes.data);
      setJobTitles(jobRes.data);
    } catch (err) {
      setError('Failed to load data');
    }
    setLoading(false);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editingId) {
        await api.updateEmployee(editingId, formData);
      } else {
        await api.createEmployee(formData);
      }
      resetForm();
      loadInitialData();
    } catch (err) {
      setError('Failed to save employee');
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Delete this employee?')) {
      await api.deleteEmployee(id);
      loadInitialData();
    }
  };

  const handleEdit = (emp) => {
    setFormData({
      full_name: emp.full_name,
      job_title: emp.job_title,
      country: emp.country,
      salary: emp.salary,
      email: emp.email || '',
      phone: emp.phone
    });
    setEditingId(emp.id);
    setView('form');
  };

  const resetForm = () => {
    setFormData({ full_name: '', job_title: '', country: '', salary: '', email: '', phone: '' });
    setEditingId(null);
  };

  const fetchCountryInsight = async () => {
    if (!selectedCountry) return;
    const res = await api.getByCountry(selectedCountry);
    setCountryInsight(res.data);
  };

  const fetchJobTitleInsight = async () => {
    if (!selectedJobTitle) return;
    const res = await api.getByJobTitle(selectedJobTitle, selectedCountry);
    setJobTitleInsight(res.data);
  };

  const formatCurrency = (val) => `$${Number(val).toLocaleString()}`;

  if (loading) return <div className="flex justify-center items-center h-screen">Loading...</div>;

  return (
    <div className="min-h-screen bg-gray-100">
      {/* Header */}
      <header className="bg-blue-600 text-white p-4 shadow">
        <div className="max-w-7xl mx-auto flex justify-between items-center">
          <h1 className="text-2xl font-bold">Salary Management Tool</h1>
          <nav className="space-x-4">
            <button onClick={() => setView('dashboard')} className={`px-3 py-1 rounded ${view === 'dashboard' ? 'bg-blue-800' : 'hover:bg-blue-700'}`}>Dashboard</button>
            <button onClick={() => setView('employees')} className={`px-3 py-1 rounded ${view === 'employees' ? 'bg-blue-800' : 'hover:bg-blue-700'}`}>Employees</button>
            <button onClick={() => { resetForm(); setView('form'); }} className={`px-3 py-1 rounded ${view === 'form' ? 'bg-blue-800' : 'hover:bg-blue-700'}`}>Add Employee</button>
          </nav>
        </div>
      </header>

      <main className="max-w-7xl mx-auto p-6">
        {error && <div className="bg-red-100 text-red-700 p-3 rounded mb-4">{error}</div>}

        {/* Dashboard View */}
        {view === 'dashboard' && summary && (
          <div>
            <h2 className="text-xl font-semibold mb-4">Salary Insights Dashboard</h2>
            
            {/* Summary Cards */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
              <div className="bg-white p-4 rounded shadow">
                <p className="text-gray-500 text-sm">Total Employees</p>
                <p className="text-2xl font-bold">{summary.total_employees}</p>
              </div>
              <div className="bg-white p-4 rounded shadow">
                <p className="text-gray-500 text-sm">Total Payroll</p>
                <p className="text-2xl font-bold">{formatCurrency(summary.total_payroll)}</p>
              </div>
              <div className="bg-white p-4 rounded shadow">
                <p className="text-gray-500 text-sm">Average Salary</p>
                <p className="text-2xl font-bold">{formatCurrency(summary.overall_avg_salary)}</p>
              </div>
              <div className="bg-white p-4 rounded shadow">
                <p className="text-gray-500 text-sm">Salary Range</p>
                <p className="text-lg font-bold">{formatCurrency(summary.overall_min_salary)} - {formatCurrency(summary.overall_max_salary)}</p>
              </div>
            </div>

            {/* Insights by Country */}
            <div className="bg-white p-4 rounded shadow mb-6">
              <h3 className="font-semibold mb-3">Salary by Country</h3>
              <div className="flex gap-2 mb-3">
                <select value={selectedCountry} onChange={(e) => setSelectedCountry(e.target.value)} className="border p-2 rounded flex-1">
                  <option value="">Select Country</option>
                  {countries.map(c => <option key={c} value={c}>{c}</option>)}
                </select>
                <button onClick={fetchCountryInsight} className="bg-blue-600 text-white px-4 py-2 rounded">Get Insights</button>
              </div>
              {countryInsight && (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-3 text-sm">
                  <div><span className="text-gray-500">Employees:</span> {countryInsight.employee_count}</div>
                  <div><span className="text-gray-500">Min:</span> {formatCurrency(countryInsight.min_salary)}</div>
                  <div><span className="text-gray-500">Max:</span> {formatCurrency(countryInsight.max_salary)}</div>
                  <div><span className="text-gray-500">Avg:</span> {formatCurrency(countryInsight.avg_salary)}</div>
                </div>
              )}
            </div>

            {/* Insights by Job Title */}
            <div className="bg-white p-4 rounded shadow mb-6">
              <h3 className="font-semibold mb-3">Salary by Job Title</h3>
              <div className="flex gap-2 mb-3">
                <select value={selectedJobTitle} onChange={(e) => setSelectedJobTitle(e.target.value)} className="border p-2 rounded flex-1">
                  <option value="">Select Job Title</option>
                  {jobTitles.map(j => <option key={j} value={j}>{j}</option>)}
                </select>
                <button onClick={fetchJobTitleInsight} className="bg-blue-600 text-white px-4 py-2 rounded">Get Insights</button>
              </div>
              {jobTitleInsight && (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-3 text-sm">
                  <div><span className="text-gray-500">Employees:</span> {jobTitleInsight.employee_count}</div>
                  <div><span className="text-gray-500">Min:</span> {formatCurrency(jobTitleInsight.min_salary)}</div>
                  <div><span className="text-gray-500">Max:</span> {formatCurrency(jobTitleInsight.max_salary)}</div>
                  <div><span className="text-gray-500">Avg:</span> {formatCurrency(jobTitleInsight.avg_salary)}</div>
                </div>
              )}
            </div>

            {/* Top Paying Countries */}
            <div className="bg-white p-4 rounded shadow">
              <h3 className="font-semibold mb-3">Top Paying Countries</h3>
              <div className="space-y-2">
                {summary.top_paying_countries?.map((c, i) => (
                  <div key={c.country} className="flex justify-between items-center">
                    <span>{i + 1}. {c.country}</span>
                    <span className="font-semibold">{formatCurrency(c.avg_salary)}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Employees List View */}
        {view === 'employees' && (
          <div>
            <h2 className="text-xl font-semibold mb-4">Employees ({employees.length})</h2>
            <div className="bg-white rounded shadow overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="p-3 text-left">Name</th>
                    <th className="p-3 text-left">Job Title</th>
                    <th className="p-3 text-left">Country</th>
                    <th className="p-3 text-left">Salary</th>
                    <th className="p-3 text-left">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {employees.slice(0, 50).map(emp => (
                    <tr key={emp.id} className="border-t hover:bg-gray-50">
                      <td className="p-3">{emp.full_name}</td>
                      <td className="p-3">{emp.job_title}</td>
                      <td className="p-3">{emp.country}</td>
                      <td className="p-3">{formatCurrency(emp.salary)}</td>
                      <td className="p-3 space-x-2">
                        <button onClick={() => handleEdit(emp)} className="text-blue-600 hover:underline">Edit</button>
                        <button onClick={() => handleDelete(emp.id)} className="text-red-600 hover:underline">Delete</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
              {employees.length > 50 && <p className="p-3 text-gray-500 text-sm">Showing 50 of {employees.length} employees</p>}
            </div>
          </div>
        )}

        {/* Add/Edit Form View */}
        {view === 'form' && (
          <div className="max-w-lg mx-auto">
            <h2 className="text-xl font-semibold mb-4">{editingId ? 'Edit Employee' : 'Add Employee'}</h2>
            <form onSubmit={handleSubmit} className="bg-white p-6 rounded shadow space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Full Name *</label>
                <input type="text" required value={formData.full_name} onChange={(e) => setFormData({...formData, full_name: e.target.value})} className="w-full border p-2 rounded" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Job Title *</label>
                <input type="text" required value={formData.job_title} onChange={(e) => setFormData({...formData, job_title: e.target.value})} className="w-full border p-2 rounded" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Country *</label>
                <input type="text" required value={formData.country} onChange={(e) => setFormData({...formData, country: e.target.value})} className="w-full border p-2 rounded" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Salary *</label>
                <input type="number" required min="1" value={formData.salary} onChange={(e) => setFormData({...formData, salary: e.target.value})} className="w-full border p-2 rounded" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Email</label>
                <input type="email" value={formData.email} onChange={(e) => setFormData({...formData, email: e.target.value})} className="w-full border p-2 rounded" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Phone * (10 digits)</label>
                <input type="text" required pattern="\d{10}" value={formData.phone} onChange={(e) => setFormData({...formData, phone: e.target.value})} className="w-full border p-2 rounded" />
              </div>
              <div className="flex gap-2">
                <button type="submit" className="bg-blue-600 text-white px-4 py-2 rounded flex-1">{editingId ? 'Update' : 'Create'}</button>
                <button type="button" onClick={() => { resetForm(); setView('employees'); }} className="bg-gray-300 px-4 py-2 rounded">Cancel</button>
              </div>
            </form>
          </div>
        )}
      </main>
    </div>
  );
}

export default App;
