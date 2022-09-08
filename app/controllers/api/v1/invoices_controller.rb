# frozen_string_literal: true

module Api
  module V1
    class InvoicesController < ApplicationController
      before_action :set_invoice, only: %i[show update destroy cancel]
      before_action :set_branch_office, only: %i[index create generate pending]

      Time.zone = 'La Paz'

      # GET /api/v1/invoices
      def index
        @invoices = @branch_office.invoices # or company?

        render json: @invoices
      end

      def pending
        @pending_invoices = @branch_office.invoices.for_sending

        render json: @pending_invoices
      end

      # GET /api/v1/invoices/1
      def show
        render json: @invoice, include: :invoice_details
      end

      # POST /api/v1/invoices
      def create
        # TODO: implement validate!

        @invoice = @branch_office.invoices.build(invoice_params)
        @company = @branch_office.company

        @invoice.company_name = @branch_office.company.name
        @invoice.company_nit = @branch_office.company.nit
        @invoice.municipality = @branch_office.city
        @invoice.phone = @branch_office.phone
        # TODO: add some scope for getting the current daily code number
        # it might not be the last one
        daily_code = @branch_office.daily_codes.last
        @invoice.cufd_code = daily_code.code
        @invoice.date = DateTime.now
        @invoice.control_code = daily_code.control_code
        @invoice.branch_office_number = @branch_office.number
        @invoice.address = @branch_office.address
        @invoice.cafc = nil # TODO: implement cafc
        @invoice.document_sector_code = 1
        @invoice.total = @invoice.subtotal
        @invoice.cash_paid = @invoice.total # TODO: implement different payments
        @invoice.invoice_status_id = 1
        activity_code = invoice_params[:invoice_details_attributes].first[:economic_activity_code]
        @economic_activity = @company.economic_activities.find_by(code: activity_code)
        @invoice.legend = @economic_activity.random_legend.description

        @invoice.invoice_details.each do |detail|
          detail.total = detail.subtotal
          detail.product = @company.products.find_by(primary_code: detail.product_code)
          detail.sin_code = detail.product.sin_code
        end
        unless @invoice.valid?
          render json: @invoice.errors, status: :unprocessable_entity
          return
        end

        if @invoice.save
          process_pending_data(@invoice)
          SendInvoiceJob.perform_later(@invoice, invoice_params[:client_code])

          render json: @invoice, include: :invoice_details, status: :created
        else
          render json: @invoice.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/invoices/1
      def update
        if @invoice.update(invoice_params)
          render json: @invoice
        else
          render json: @invoice.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/invoices/1
      def destroy
        @invoice.destroy
      end

      # POST /api/v1/invoices/1/cancel
      def cancel
        if @invoice.cancellation_date?
          return render json: "La factura ya fue anulada el #{@invoice.cancellation_date}",
                        status: :unprocessable_entity
        end

        CancelInvoiceJob.perform_later(@invoice)

        # TODO: send cancellation_reason_id in body
        @invoice.update(cancellation_date: DateTime.now, cancellation_reason_id: 1)
        render json: @invoice
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_invoice
        @invoice = Invoice.find(params[:id])
      end

      def set_branch_office
        @branch_office = BranchOffice.find(params[:branch_office_id])
      end

      # Only allow a list of trusted parameters through.
      def invoice_params
        params.require(:invoice).permit(:business_name, :document_type, :business_nit, :complement, :client_code, :payment_method,
                                        :card_number, :subtotal, :gift_card_total, :discount, :exception_code, :cafc,
                                        :currency_code, :exchange_rate, :currency_total, :user, :document_sector_code,
                                        :cancellation_reason_id, :point_of_sale,
                                        invoice_details_attributes: %i[product_code description quantity measurement_id
                                                                       unit_price discount subtotal serial_number imei_code
                                                                       economic_activity_code])
      end

      def process_pending_data(invoice)
        invoice.number = invoice_number
        invoice.cuf = cuf(invoice.date, invoice.number, invoice.control_code)
        # TODO: implement paper size: 1 roll, 2 half office or half letter
        invoice.qr_content = qr_content(invoice.company_nit, invoice.cuf, invoice.number, 1)
        invoice.save
      end

      def cuf(invoice_date, invoice_number, control_code)
        nit = @branch_office.company.nit.rjust(13, '0')
        date = invoice_date.strftime('%Y%m%d%H%M%S%L')
        branch_office = @branch_office.number.to_s.rjust(4, '0')
        modality = '2' # TODO: save modality in company or branch office
        generation_type = '1' # TODO: add generation types for: online, offline and massive
        invoice_type = '1' # TODO: add invoice types table
        sector_document_type = '1'.rjust(2, '0') # TODO: add sector types table
        number = invoice_number.to_s.rjust(10, '0')
        point_of_sale = '0000' # TODO: implement point of sales for each branch office

        long_code = nit + date + branch_office + modality + generation_type + invoice_type + sector_document_type + number +
                    point_of_sale
        mod_11_value = module_eleven(long_code, 9)
        hex_code = hex_base(mod_11_value.to_i)
        (hex_code + control_code).upcase
      end

      def invoice_number
        # TODO: add some scope for getting the current cuis code
        # it might not be the last one
        cuis_code = @branch_office.cuis_codes.last
        current_number = cuis_code.current_number
        cuis_code.increment!
        current_number
      end

      # TODO: refactor module_eleven and hex_base, move them to a calculator class
      def module_eleven(code, limit)
        sum = 0
        multiplier = 2
        code.reverse.each_char.with_index do |character, _i|
          sum += multiplier * character.to_i
          multiplier += 1
          multiplier = 2 if multiplier > limit
        end
        digit = sum % 11
        last_char = digit == 10 ? '1' : digit.to_s
        code + last_char
      end

      def hex_base(value)
        value.to_s(16)
      end

      def qr_content(nit, cuf, number, page_size)
        base_url = ENV.fetch('siat_url', nil)
        params = { nit: nit, cuf: cuf, numero: number, t: page_size }
        "#{base_url}?#{params.to_param}"
      end
    end
  end
end
