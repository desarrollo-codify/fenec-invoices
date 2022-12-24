# frozen_string_literal: true

module Api
  module V1
    class AccountingTransactionsController < ApplicationController
      before_action :set_company, only: %i[index create]
      before_action :set_accounting_transaction, only: %i[show update destroy]

      # GET /api/v1/companies/1/accounting_transactions
      def index
        @accounting_transactions = @company.accounting_transactions.includes(:currency, :transaction_type, :cycle, :entries)

        render json: @accounting_transactions.as_json(include: [{ currency: { only: %i[id description abbreviation] } },
                                                                { cycle: { only: %i[id year] } },
                                                                { transaction_type: { only: %i[id description] } },
                                                                { entries: { except: %i[created_at updated_at] } }])
      end

      # GET /api/v1/accounting_transactions/1
      def show
        render json: @accounting_transaction.as_json(include: [{ currency: { only: %i[id description abbreviation] } },
                                                               { cycle: { only: %i[id year] } },
                                                               { transaction_type: { only: %i[id description] } },
                                                               { entries: { include: {
                                                                              account: { except: %i[created_at updated_at] }
                                                                            },
                                                                            except: %i[created_at updated_at] } }])
      end

      # POST /api/v1/companies/1/accounting_transactions
      def create
        @accounting_transaction = @company.accounting_transactions.build(accounting_transaction_params)
        add_number

        if @accounting_transaction.save
          @accounting_transaction.accounting_transaction_logs.create(full_name: 'current_user.full_name', action: 'CREATE',
                                                                     log_action: @accounting_transaction.as_json(include: :entires))
          render json: @accounting_transaction, status: :created
        else
          render json: @accounting_transaction.errors.full_messages, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/accounting_transactions/1
      def update
        if @accounting_transaction.update(accounting_transaction_params)
          @accounting_transaction.accounting_transaction_logs.create(full_name: 'current_user.full_name', action: 'UPDATE',
                                                                     log_action: @accounting_transaction.as_json(include: :entires))
          render json: @accounting_transaction
        else
          render json: @accounting_transaction.errors.full_messages, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/accounting_transactions/1
      def destroy
        @accounting_transaction.destroy
      end

      private

      def add_number
        cycle = Cycle.find(@accounting_transaction.cycle_id)
        transaction_type = TransactionType.find(@accounting_transaction.transaction_type_id)

        if TransactionNumber.find_by(cycle_id: cycle.id, transaction_type_id: transaction_type.id).present?
          transaction_number = TransactionNumber.find_by(cycle_id: cycle.id, transaction_type_id: transaction_type.id)
          transaction_number.increment!
        else
          transaction_number = TransactionNumber.create(cycle: cycle, transaction_type: transaction_type)
        end
        @accounting_transaction.number = transaction_number.number
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_accounting_transaction
        @accounting_transaction = AccountingTransaction.find(params[:id])
      end

      def set_company
        @company = Company.find(params[:company_id])
      end

      # Only allow a list of trusted parameters through.
      def accounting_transaction_params
        params.require(:accounting_transaction).permit(:date, :number, :receipt, :gloss, :type, :currency_id,
                                                       :cycle_id, :company_id, :transaction_type_id,
                                                       entries_attributes: %i[debit_bs credit_bs debit_sus credit_sus
                                                                              account_id accounting_transaction_id])
      end
    end
  end
end
