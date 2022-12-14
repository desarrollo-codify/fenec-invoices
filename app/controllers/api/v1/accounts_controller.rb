# frozen_string_literal: true

require 'csv'

module Api
  module V1
    class AccountsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_company, only: %i[index create import for_transactions]
      before_action :set_account, only: %i[show update destroy]

      # GET /api/v1/companies/1/accounts
      def index
        @accounts = @company.accounts

        render json: @accounts
      end

      # GET /api/v1/accounts/1
      def show
        render json: @account
      end

      # POST /api/v1/companies/1/accounts
      def create
        @account = @company.accounts.build(account_params)

        if @account.save
          render json: @account, status: :created
        else
          render json: @account.errors.full_messages, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/accounts/1
      def update
        if @account.update(update_account_params)
          render json: @account
        else
          render json: @account.errors.full_messages, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/accounts/1
      def destroy
        @account.destroy
        render json: { message: 'Se ha eliminado correctamente la cuenta.' }, status: :no_content
      rescue StandardError
        render json: { message: 'No se ha podido eliminar la cuenta.' },
               status: :unprocessable_entity
      end

      # POST /api/v1/companies/1/accounts/import
      def import
        if import_params[:csv].content_type.include?('csv')
          csv_text = File.read(import_params[:csv].tempfile)
          csv = CSV.parse(csv_text, headers: true, col_sep: ';')
          cycle = Cycle.find(import_params[:cycle_id])
          levels = AccountLevel.all
          account_types = AccountType.all
          count = 0

          csv.each do |row|
            number, description, level = row
            next if number.empty?

            number = number.chop while number.last == '0' && level < 5 # TODO: something like @company.settings.levels
            account = Account.new
            account.number = number[1]
            account.description = description[1]
            account.account_level_id = levels.find_by(initial: level[1]).id
            digit = account.number[0].to_i
            account.account_type_id = account_types.find(digit).id
            account.cycle_id = cycle.id
            account.company_id = @company.id
            count += 1 if account.save
          end
        end

        render json: count
      end

      def for_transactions
        cycle = @company.cycles.current.id
        level = @company.company_setting.account_levels
        accounts = @company.accounts.for_transactions(level, cycle)

        render json: accounts.as_json(except: %i[created_at updated_at])
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
        params.require(:account).permit(:number, :description, :amount, :percentage, :cycle_id, :account_level_id, :account_type_id)
      end

      def update_account_params
        params.require(:account).permit(:number, :description, :amount, :percentage, :account_level_id, :account_type_id)
      end

      def import_params
        params.permit(:company_id, :csv, :cycle_id)
      end
    end
  end
end
