require 'csv'

class Api::V1::AccountsController < ApplicationController
  before_action :set_company, only: %i[ index create import ]
  before_action :set_account, only: %i[ show update destroy ]

  # GET /api/v1/companies/1/accounts
  def index
    @accounts = Account.all

    render json: @accounts
  end

  # GET /api/v1/accounts/1
  def show
    render json: @account
  end

  # POST /api/v1/companies/1/accounts
  def create
    @account = Account.new(account_params)

    if @account.save
      render json: @account, status: :created, location: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/accounts/1
  def update
    if @account.update(account_params)
      render json: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/accounts/1
  def destroy
    @account.destroy
  end

  # DELETE /api/v1/companies/1/accounts/import
  def import 
    if import_params[:csv].content_type.include?('csv')
      csv_text = File.read(import_params[:csv].tempfile)
      csv = CSV.parse(csv_text, headers: true, col_sep: ";")
      cycle = Cycle.find(import_params[:cycle_id])
      levels = AccountLevel.all
      account_types = AccountType.all
      count = 0
      
      csv.each do |row|
        number, description, level = row
        if !number.empty?
          while number.last == "0" && level < 5 do # TODO: something like @company.settings.levels
            number = number.chop
          end
          account = Account.new
          account.number = number[1]
          account.description = description[1]
          account.account_level_id = levels.find_by(initial: level[1]).id
          digit = account.number[0].to_i
          account.account_type_id = account_types.find(digit).id
          account.cycle_id = cycle.id
          account.company_id = @company.id
          if account.save
            count += 1
          end
        end
      end
    end

    render json: count
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    def set_company
      @company = Company.find(params[:company_id])
    end

    # Only allow a list of trusted parameters through.
    def account_params
      params.fetch(:account, {})
    end

    def import_params
      params.permit(:company_id, :csv, :cycle_id)
    end
end
