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
        @errors = []
        @accounting_transaction = @company.accounting_transactions.build(accounting_transaction_params)
        validate!(@accounting_transaction)
        return render json: @errors, status: :unprocessable_entity if @errors.any?

        add_number

        if @accounting_transaction.save
          @accounting_transaction.accounting_transaction_logs.create(full_name: 'current_user.full_name', action: 'CREATE',
                                                                     log_action: @accounting_transaction.as_json(include: :entries))
          render json: @accounting_transaction, status: :created
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
          @accounting_transaction.accounting_transaction_logs.create(full_name: 'current_user.full_name', action: 'UPDATE',
                                                                     log_action: @accounting_transaction.as_json(include: :entries))
          render json: @accounting_transaction
        else
          render json: @accounting_transaction.errors.full_messages, status: :unprocessable_entity
        end
      end

      private

      def validate!(_accounting_transaction)
        @errors << 'No se puede crear un comprobante si no existe una gestión abierta.' unless @company.cycles.current.present?
      end

      def validate_update!(accounting_transaction, params, _is_gloss)
        @errors << 'No se puede editar un comprobante de gestiones cerradas.' unless accounting_transaction.cycle.status == 'ABIERTA'

        @errors << 'No se puede editar el número de comprobantes' if params[:number].present? && accounting_transaction.number != params[:number]

        if params[:transaction_type_id].present? && accounting_transaction.transaction_type_id != params[:transaction_type_id]
          @errors << 'No se puede editar el tipo de transacción una vez creado el comprobante.'
        end

        validate_date(accounting_transaction, params) unless accounting_transaction.date.to_date == Date.today
      end

      def validate_date(accounting_transaction, params)
        if accounting_transaction.date != params[:date].to_date
          return @errors << 'Para realizar cambios en un día distinto al de creación, se requiere un nuevo comprobante.'
        end
        if accounting_transaction.receipt != params[:receipt]
          return @errors << 'Para realizar cambios en un día distinto al de creación, se requiere un nuevo comprobante.'
        end
        if accounting_transaction.currency_id != params[:currency_id]
          return @errors << 'Para realizar cambios en un día distinto al de creación, se requiere un nuevo comprobante.'
        end

        params[:entries_attributes].each do |entry|
          id = entry[:id] if entry[:id].present?

          return @errors << 'No se pueden añadir asientos nuevos un día distinto al de creación del comprobante.' unless id.present?

          entry_current = Entry.find(id)
          if entry[:debit_bs] != entry_current.debit_bs
            return @errors << 'No se pueden realizar cambios en algun asiento un día distinto al de creación del comprobante.'
          end
          if entry[:credit_bs] != entry_current.credit_bs
            return @errors << 'No se pueden realizar cambios en algun asiento un día distinto al de creación del comprobante.'
          end
          if entry[:debit_sus] != entry_current.debit_sus
            return @errors << 'No se pueden realizar cambios en algun asiento un día distinto al de creación del comprobante.'
          end
          if entry[:credit_sus] != entry_current.credit_sus
            return @errors << 'No se pueden realizar cambios en algun asiento un día distinto al de creación del comprobante.'
          end
          if entry[:account_id] != entry_current.account_id
            return @errors << 'No se pueden realizar cambios en algun asiento un día distinto al de creación del comprobante.'
          end
        end
      end

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
        params.require(:accounting_transaction).permit(:date, :receipt, :gloss, :type, :currency_id,
                                                       :cycle_id, :company_id, :transaction_type_id,
                                                       entries_attributes: %i[id debit_bs credit_bs debit_sus credit_sus
                                                                              account_id accounting_transaction_id])
      end
    end
  end
end
