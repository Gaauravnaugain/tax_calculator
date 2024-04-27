class Employee < ApplicationRecord
  validates :first_name, :last_name, :email, :employee_id, :doj, :salary, presence: true
  validates :employee_id, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :salary, numericality: { greater_than: 0 }
  validate :validate_phone_numbers_uniqueness_within_employee

  private

  	def validate_phone_numbers_uniqueness_within_employee
	  if phone_numbers.present?
	    numbers = phone_numbers.split(',').map(&:strip)

	    conditions = numbers.map { |number| "phone_numbers LIKE '%#{number}%'" }.join(' OR ')
	    existing_employee = Employee.where(conditions).where.not(id: id).first

	    if existing_employee
	      errors.add(:phone_numbers, "contains phone number(s) that are already assigned to another employee")
	    end
	  end
	end
end