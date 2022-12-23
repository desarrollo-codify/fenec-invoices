# frozen_string_literal: true

module Api
  module V1
    class AccountingTransactionsController < ApplicationController
      before_action :set_company, only: %i[index create]
      before_action :set_accounting_transaction, only: %i[show update destroy update_gloss]

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
        @errors = []
        @accounting_transaction = @company.accounting_transactions.build(accounting_transaction_params)
        validate!(@accounting_transaction)
        return render json: @errors, status: :unprocessable_entity if @errors.any?

        @accounting_transaction.number = AccountingTransaction.any? ? AccountingTransaction.last.number + 1 : 1

        if @accounting_transaction.save
          render json: @accounting_transaction.as_json(include: [{ currency: { only: %i[id description abbreviation] } },
                                                                 { cycle: { only: %i[id year] } },
                                                                 { transaction_type: { only: %i[id description] } },
                                                                 { entries: { except: %i[created_at updated_at] } }]), status: :created
        else
          render json: @accounting_transaction.errors.full_messages, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/accounting_transactions/1
      def update
        @errors = []
        validate_update!(@accounting_transaction, accounting_transaction_params, false)
        return render json: @errors, status: :unprocessable_entity if @errors.any?

        if @accounting_transaction.update(accounting_transaction_params)
          render json: @accounting_transaction.as_json(include: [{ currency: { only: %i[id description abbreviation] } },
                                                                 { cycle: { only: %i[id year] } },
                                                                 { transaction_type: { only: %i[id description] } },
                                                                 { entries: { except: %i[created_at updated_at] } }])
        else
          render json: @accounting_transaction.errors.full_messages, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/accounting_transactions/1/update_gloss
      def update_gloss
        @errors = []
        validate_update!(@accounting_transaction, accounting_transaction_gloss_params, true)
        return render json: @errors, status: :unprocessable_entity if @errors.any?

        if @accounting_transaction.update(accounting_transaction_gloss_params)
          render json: @accounting_transaction.as_json(include: [{ currency: { only: %i[id description abbreviation] } },
                                                                 { cycle: { only: %i[id year] } },
                                                                 { transaction_type: { only: %i[id description] } },
                                                                 { entries: { except: %i[created_at updated_at] } }])
        else
          render json: @accounting_transaction.errors.full_messages, status: :unprocessable_entity
        end
      end

      private

      def validate!(_accounting_transaction)
        @errors << 'No se puede crear un comprobante si no existe una gestión abierta.' unless @company.cycles.current.present?
      end

      def validate_update!(accounting_transaction, params, is_gloss)
        @errors << 'No se puede editar un comprobante de gestiones cerradas.' unless accounting_transaction.cycle.status == 'ABIERTA'

        return if is_gloss

        @errors << 'No se puede editar el número de comprobantes' if params[:number].present? && accounting_transaction.number != params[:number]

        if params[:transaction_type_id].present? && accounting_transaction.transaction_type_id != params[:transaction_type_id]
          @errors << 'No se puede editar el tipo de transacción una vez creado el comprobante.'
        end

        return if accounting_transaction.date.to_date == Date.today

        @errors << 'Para realizar cambios en un día distinto al de creación, se requiere un nuevo comprobante.'
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
        params.require(:accounting_transaction).permit(:date, :receipt, :gloss, :type, :currency_id,
                                                       :cycle_id, :company_id, :transaction_type_id,
                                                       entries_attributes: %i[id debit_bs credit_bs debit_sus credit_sus
                                                                              account_id accounting_transaction_id])
      end

      def accounting_transaction_gloss_params
        params.require(:accounting_transaction_gloss).permit(:gloss)
      end
    end
  end
end
