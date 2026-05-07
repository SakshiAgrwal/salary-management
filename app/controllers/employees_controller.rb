# frozen_string_literal: true

class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :update, :destroy]

  # GET /employees
  def index
    scoped_employees = Employee.all
    scoped_employees = apply_filters(scoped_employees)

    paginated = paginated_relation(scoped_employees)

    render json: {
      data: paginated[:records],
      meta: paginated[:meta]
    }
  end

  # GET /employees/:id
  def show
    render json: @employee
  end

  # POST /employees
  def create
    @employee = Employee.new(employee_params)

    if @employee.save
      render json: @employee, status: :created, location: @employee
    else
      render json: { errors: @employee.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PATCH/PUT /employees/:id
  def update
    if @employee.update(employee_params)
      render json: @employee
    else
      render json: { errors: @employee.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /employees/:id
  def destroy
    @employee.destroy
    head :no_content
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:full_name, :job_title, :country, :salary, :email, :phone)
  end

  def apply_filters(relation)
    relation = relation.where('LOWER(full_name) LIKE ?', "%#{params[:q].downcase}%") if params[:q].present?
    relation = relation.where(country: params[:country]) if params[:country].present?
    relation = relation.where(job_title: params[:job_title]) if params[:job_title].present?

    relation
  end

  def paginated_relation(relation)
    page = params.fetch(:page, 1).to_i
    per_page = params.fetch(:per_page, 25).to_i
    per_page = 1 if per_page < 1
    per_page = 100 if per_page > 100

    total = relation.count
    total_pages = (total / per_page.to_f).ceil

    records = relation.order(created_at: :desc)
                     .offset((page - 1) * per_page)
                     .limit(per_page)

    {
      records: records,
      meta: {
        total: total,
        page: page,
        per_page: per_page,
        total_pages: total_pages
      }
    }
  end
end
