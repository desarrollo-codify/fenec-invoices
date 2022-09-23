# frozen_string_literal: true

module Api
  module V1
    class InvoicesController < ApplicationController
      before_action :set_invoice, only: %i[show update destroy cancel resend]
      before_action :set_branch_office, only: %i[index create generate pending]
      require 'invoice_xml'
      require 'siat_available'
      require 'verify_nit'
      Time.zone = 'La Paz'

      # GET /api/v1/invoices
      def index
        @invoices = @branch_office.company.invoices.includes(:branch_office, :invoice_status, :invoice_details).descending
        render json: @invoices.as_json(include: [{ branch_office: { only: %i[id number name] } },
                                                 { invoice_status: { only: %i[id description] } },
                                                 { invoice_details: { except: %i[created_at updated_at] } }])
      end

      def pending
        @pending_invoices = @branch_office.invoices.for_sending
        render json: @pending_invoices
      end

      # GET /api/v1/invoices/1
      def show
        result = @invoice.as_json(include: [{ branch_office: { only: %i[id number name] } },
                                            { invoice_status: { only: %i[id description] } },
                                            { invoice_details: { include: {
                                                                   measurement: { except: %i[created_at updated_at] }
                                                                 },
                                                                 except: %i[created_at updated_at] } }])
        result = result.merge(identity_document: DocumentType.find_by(code: @invoice.document_type))
        render json: result
      end

      # POST /api/v1/invoices
      # rubocop:disable all
      def create
        # TODO: implement validate!

        @invoice = @branch_office.invoices.build(invoice_params)
        @company = @branch_office.company

        @invoice.company_name = @branch_office.company.name
        @invoice.company_nit = @branch_office.company.nit
        @invoice.municipality = @branch_office.city
        @invoice.phone = @branch_office.phone

        daily_code = @branch_office.daily_codes.where(point_of_sale: invoice_params[:point_of_sale]).current
        @invoice.cufd_code = daily_code.code

        client = @company.clients.find_by(code: invoice_params[:client_code])
        @invoice.business_name = client.name
        @invoice.business_nit = client.nit
        @invoice.complement = client.complement
        @invoice.document_type = client.document_type_id

        @invoice.date = DateTime.now
        @invoice.control_code = daily_code.control_code
        @invoice.branch_office_number = @branch_office.number
        @invoice.address = @branch_office.address
        activity_code = invoice_params[:invoice_details_attributes].first[:economic_activity_code]
        @economic_activity = @company.economic_activities.find_by(code: activity_code)
        contingency = Contingency.where(point_of_sale_id: invoice_params[:point_of_sale]).pending.last # TODO: Refactor
        @invoice.cafc = if contingency.present? && params[:is_manual].present?
                          contingency.significative_event_id >= 5 ? @economic_activity.contingency_codes.first.code : nil
                        end
        @invoice.document_sector_code = 1
        @invoice.total = @invoice.subtotal - @invoice.discount - @invoice.gift_card_total - @invoice.advance
        @invoice.invoice_status_id = 1
        @economic_activity = @company.economic_activities.find_by(code: activity_code)
        @invoice.legend = @economic_activity.random_legend.description
        @invoice.graphic_representation_text = 'Este documento es la Representación Gráfica de un Documento Fiscal Digital emitido en una modalidad de facturación en línea'
        @invoice.card_number = nil
        
        if [2, 10, 18, 40, 43, 83, 86].include? @invoice.payment_method
          unless @invoice.card_paid.positive?
            return render json: 'No se ha insertado el monto del pago por tarjeta.',
                          status: :unprocessable_entity
          end

          card_number = invoice_params[:card_number]
          card_number = "#{card_number[0, 4]}00000000#{card_number[card_number.length - 4, 4]}"
          @invoice.card_number = card_number
        end

        if (@invoice.payment_method == 7 || @invoice.payment_method == 13) && @invoice.qr_paid.zero?
          return render json: 'No se ha insertado el monto del pago por transferencia bancaria.',
                        status: :unprocessable_entity
        end

        @invoice.invoice_details.each do |detail|
          detail.total = detail.subtotal - detail.discount
          detail.product = @company.products.find_by(primary_code: detail.product_code)
          detail.description = detail.product.description
          detail.sin_code = detail.product.sin_code
        end

        if @invoice.document_type == 5
          @invoice.exception_code = 1
          if SiatAvailable.available(@invoice, false)
            if VerifyNit.verify(@invoice.business_nit, @branch_office)
              @invoice.exception_code = nil
            end
          end
        end

        unless @invoice.valid?
          render json: { message: @invoice.errors.first }, status: :unprocessable_entity
          return
        end

        if @invoice.save
          point_of_sale = @branch_office.point_of_sales.find_by(code: @invoice.point_of_sale)
          ProcessInvoiceJob.perform_later(@invoice, point_of_sale)

          render json: @invoice.as_json(only: %i[id total]), status: :created
        else
          render json: { message: @invoice.errors.first }, status: :unprocessable_entity
        end
      end
      # rubocop:enable all

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
        if @invoice.cancel_sent_at == true
          return render json: "La factura ya fue anulada el #{@invoice.cancellation_date}",
                        status: :unprocessable_entity
        end
        @reason = params[:reason]
        @invoice.update(cancellation_date: DateTime.now, cancellation_reason_id: @reason, invoice_status_id: 2)
        CancelInvoiceJob.perform_later(@invoice, @reason) unless @invoice.sent_at.nil?

        render json: @invoice.as_json(only: %i[id number total cuf cancellation_date cancel_sent_at]), status: :created
      end

      def resend
        @company = @invoice.branch_office.company
        @client = @company.clients.find_by(code: @invoice.client_code)
        @branch_office = @invoice.branch_office
        xml = InvoiceXml.generate(@invoice)
        filename = "#{Rails.root}/public/tmp/mails/#{@invoice.cuf}.xml"
        File.write(filename, xml)
        begin
          InvoiceMailer.with(client: @client, invoice: @invoice, sender: @company.company_setting).send_invoice.deliver_now
        rescue StandardError => e
          p e.message
        end
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
                                        :cancellation_reason_id, :point_of_sale, :cash_paid, :qr_paid, :card_paid, :gift_card,
                                        :online_paid,
                                        invoice_details_attributes: %i[product_code description quantity measurement_id
                                                                       unit_price discount subtotal serial_number imei_code
                                                                       economic_activity_code])
      end
    end
  end
end
