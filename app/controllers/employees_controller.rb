class EmployeesController < ApplicationController
	def create
    @employee = Employee.new(employee_params)
    if @employee.save
      render json: { status: 'Employee created successfully' }, status: :created
    else
      render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def tax_deduction
    employees = Employee.all
    financial_year_start = Date.new(Date.today.year, 4, 1)
    financial_year_end = financial_year_start.next_year - 1

    tax_results = employees.map do |employee|
      tax_details = calculate_tax(employee, financial_year_start, financial_year_end)
      {
        employee_id: employee.employee_id,
        first_name: employee.first_name,
        last_name: employee.last_name,
        yearly_salary: tax_details[:yearly_salary],
        tax_amount: tax_details[:tax_amount],
        cess_amount: tax_details[:cess_amount]
      }
    end

    render json: { tax_deductions: tax_results }, status: :ok
  end

  private

  def employee_params
    params.require(:employee).permit(:employee_id, :first_name, :last_name, :email, :phone_numbers, :doj, :salary)
  end

	def calculate_tax(employee, financial_year_start, financial_year_end)
	  total_salary = calculate_total_salary(employee, financial_year_start, financial_year_end)

	  tax_amount = 0
	  cess_amount = 0

	  if total_salary > 1000000
	    tax_amount += (total_salary - 1000000) * 0.20
	    total_salary = 1000000
	  end

	  if total_salary > 500000
	    tax_amount += [total_salary - 500000, 500000 - 250000].min * 0.10
	    total_salary = 500000
	  end

	  if total_salary > 250000
	    tax_amount += [total_salary - 250000, 250000].min * 0.05
	  end

	  # Calculate cess for amount above 2500000
	  if total_salary > 2500000
	    cess_amount = (total_salary - 2500000) * 0.02
	  end

	  {
	    yearly_salary: total_salary,
	    tax_amount: tax_amount,
	    cess_amount: cess_amount
	  }
	end

	def calculate_total_salary(employee, financial_year_start, financial_year_end)
	  doj = employee.doj

	  start_date = [doj, financial_year_start].max
	  end_date = [doj + 1.year - 1.day, financial_year_end].min

	  months_worked = ((end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month) + 1).to_f

	  days_in_start_month = (start_date.end_of_month.day - start_date.day + 1).to_f
	  days_in_end_month = end_date.day.to_f
	  days_worked = days_in_start_month / start_date.end_of_month.day + days_in_end_month / end_date.end_of_month.day

	  if start_date.year == end_date.year && start_date.month == end_date.month
	    days_worked = days_in_start_month
	  end

	  fraction_of_month_worked = days_worked / start_date.end_of_month.day

	  total_months_worked = months_worked - 1 + fraction_of_month_worked

	  total_salary = employee.salary * total_months_worked

	  total_salary
	end

end
