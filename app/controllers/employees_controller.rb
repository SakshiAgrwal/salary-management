# frozen_string_literal: true

class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :update, :destroy]

  # GET /employees
  def index
    @employees = Employee.all
    render json: @employees
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
end
