Rails.application.routes.draw do
  resources :employees, only: [:create]
  get '/employees/tax_deduction', to: 'employees#tax_deduction'
end
