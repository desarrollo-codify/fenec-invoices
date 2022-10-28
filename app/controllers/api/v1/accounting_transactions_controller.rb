# frozen_string_literal: true

module Api
  module V1
    class AccountingTransactionsController < ApplicationController
      before_action :set_company, only: %i[index create]
      before_action :set_accounting_transaction, only: %i[show update destroy]

      # GET /accounting_transactions
      def index
        @accounting_transactions = @company.accounting_transactions.includes(:currency, :transaction_type, :cycle, :entries)

        @invoices

        render json: @accounting_transactions.as_json(include: [{ currency: { only: %i[id description abbreviation] } },
                                                                { cycle: { only: %i[id year] } },
                                                                { transaction_type: { only: %i[id description] } },
                                                                { entries: { except: %i[created_at updated_at] } }])
      end

      # GET /accounting_transactions/1
      def show
        render json: @accounting_transaction.as_json(include: [{ currency: { only: %i[id description abbreviation] } },
                                                               { cycle: { only: %i[id year] } },
                                                               { transaction_type: { only: %i[id description] } },
                                                               { entries: { include: {
                                                                              account: { except: %i[created_at updated_at] }
                                                                            },
                                                                            except: %i[created_at updated_at] } }])
      end

      # POST /accounting_transactions
      def create
        @accounting_transaction = @company.accounting_transactions.build(accounting_transaction_params)
        @accounting_transaction.number = AccountingTransaction.any? ? AccountingTransaction.last.number + 1 : 1

        if @accounting_transaction.save
          render json: @accounting_transaction, status: :created
        else
          render json: @accounting_transaction.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /accounting_transactions/1
      def update
        if @accounting_transaction.update(accounting_transaction_params)
          render json: @accounting_transaction
        else
          render json: @accounting_transaction.errors, status: :unprocessable_entity
        end
      end

      # DELETE /accounting_transactions/1
      def destroy
        @accounting_transaction.destroy
      end

      private

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
