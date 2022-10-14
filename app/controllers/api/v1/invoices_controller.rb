# frozen_string_literal: true

module Api
  module V1
    class InvoicesController < ApplicationController
      before_action :set_invoice, only: %i[show update destroy cancel resend verify_status]
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
      def create
        @invoice = @branch_office.invoices.build(invoice_params)
        @errors = []
        validate!(@invoice)
        return render json: @errors, status: :unprocessable_entity if @errors.any?

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
        @invoice.document_type = client.document_type.code

        @invoice.date ||= DateTime.now
        @invoice.control_code = daily_code.control_code
        @invoice.branch_office_number = @branch_office.number
        @invoice.address = @branch_office.address
        activity_code = invoice_params[:invoice_details_attributes].first[:economic_activity_code]
        @economic_activity = @company.economic_activities.find_by(code: activity_code)
        @invoice.document_sector_code = 1
        @invoice.total = @invoice.subtotal - @invoice.discount - @invoice.advance
        @invoice.amount_payable = @invoice.total - @invoice.gift_card_total
        @invoice.invoice_status_id = 1
        @invoice.legend = @economic_activity.random_legend.description
        @invoice.graphic_representation_text = 'Este documento es la Representación Gráfica de un Documento Fiscal Digital ' \
                                               'emitido en una modalidad de facturación en línea'
        @invoice.card_number = nil

        if [2, 10, 18, 40, 43].include? @invoice.payment_method
          card_number = invoice_params[:card_number]
          card_number = "#{card_number[0, 4]}00000000#{card_number[card_number.length - 4, 4]}"
          @invoice.card_number = card_number
        end

        @invoice.invoice_details.each do |detail|
          detail.total = detail.subtotal - detail.discount
          detail.product = @company.products.find_by(primary_code: detail.product_code)
          detail.description = detail.product.description
          detail.sin_code = detail.product.sin_code
        end

        if @invoice.document_type == 5
          @invoice.exception_code = 1
          if SiatAvailable.available(@invoice, false) && VerifyNit.verify(@invoice.business_nit, @branch_office)
            @invoice.exception_code = nil
          end
        end

        unless @invoice.valid?
          render json: { message: @invoice.errors.first }, status: :unprocessable_entity
          return
        end

        if @invoice.save
          point_of_sale = @branch_office.point_of_sales.find_by(code: @invoice.point_of_sale)
          ProcessInvoiceJob.perform_later(@invoice, point_of_sale, @economic_activity)

          render json: @invoice.as_json(only: %i[id total]), status: :created
        else
          render json: { message: @invoice.errors.first }, status: :unprocessable_entity
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
        render json: "La factura #{@invoice.number} fue reenviada."
      end

      def verify_status
        invoice = []
        invoice << @invoice
        InvoiceStatusJob.perform_now(invoice)

        render json: @invoice.invoice_logs.last, status: :ok
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
                                        :online_paid, :is_manual, :date,
                                        invoice_details_attributes: %i[product_code description quantity measurement_id
                                                                       unit_price discount subtotal serial_number imei_code
                                                                       economic_activity_code])
      end

      def validate!(invoice)
        branch_office = invoice.branch_office
        company = branch_office.company
        validate_cuis(branch_office, invoice)
        validate_cufd(branch_office, invoice)
        validate_sync(company)
        validate_product(invoice, company)
        validate_invoice_detail_measurement(invoice.invoice_details)
        validate_invoice_statuses(invoice)
        validate_client(company, invoice)
        validate_document_types(company, invoice)
        validate_payment_methods(invoice)
        validate_manual_invoice(invoice, company)
      end

      def validate_cuis(branch_office, invoice)
        return if branch_office.cuis_codes.where(point_of_sale: invoice.point_of_sale).current.present?

        @errors << 'El CUIS del punto de venta no ha sido generado.'
      end

      def validate_cufd(branch_office, invoice)
        return if branch_office.daily_codes.where(point_of_sale: invoice.point_of_sale).current.present?

        @errors << 'El CUFD del punto de venta no ha sido generado.'
      end

      def validate_sync(company)
        @errors << 'No se han sincronizado las actividades economicas de la compañia.' unless company.economic_activities.present?
        # company.economic_activities.each do |economic_activity|
        #   unless economic_activity.legends.present?
        #     @errors << 'No se han sincronizado las leyendas de cada actividad economicas de la compañia.'
        #   end
        # end
      end

      def validate_product(invoice, company)
        product_codes = invoice.invoice_details.pluck(:product_code).uniq
        products = company.products.where(primary_code: product_codes)

        @errors << 'No se han insertado producto por cada detalle de factura.' unless product_codes.length == products.length

        products.each do |product|
          @errors << 'El producto registrado no se encuentra homologado.' unless product.sin_code.present?
        end
      end

      def validate_invoice_detail_measurement(invoice_details)
        invoice_details.each do |detail|
          @errors << 'No se ha indica el tipo de unidad del producto.' unless detail.measurement_id.present?
        end
      end

      def validate_invoice_statuses(_invoice)
        @errors << 'No se encuentran registrados los estados de factura en la BD.' unless InvoiceStatus.all.present?
      end

      def validate_client(company, invoice)
        @errors << 'No se ha seleccionado un cliente valido.' unless company.clients.find_by(code: invoice.client_code).present?
      end

      def validate_document_types(company, invoice)
        client = company.clients.find_by(code: invoice.client_code)
        @errors << 'El tipo de documento insertado indica que debe ser de tipo númerico.' if ([1,
                                                                                               5].include? client.document_type_id) &&
                                                                                             client.nit.scan(/\D/).any?
      end

      def validate_payment_methods(invoice)
        @errors << 'No se ha insertado el metodo de pago.' unless invoice.payment_method
        # - Are there payment methods for card paid?
        validate_card_paid(invoice)
        # - Are there payment methods for qr paid?
        @errors << 'No se ha insertado el monto del pago por transferencia bancaria.' if ([7, 13, 18, 64,
                                                                                           67].include? invoice.payment_method) &&
                                                                                         invoice.qr_paid.zero?
        # - Are there payment methods for online paid?
        @errors << 'No se ha insertado el monto del pago online.' if ([33, 38, 43, 67,
                                                                       78].include? invoice.payment_method) &
                                                                     invoice.online_paid.zero?
        # - Are there payment methods for gift card?
        @errors << 'No se ha insertado el monto del pago por Gift Card.' if ([27, 35, 40, 64,
                                                                              78].include? invoice.payment_method) &&
                                                                            invoice.gift_card_total.zero?
      end

      def validate_card_paid(invoice)
        return unless [2, 10, 18, 40, 43].include? invoice.payment_method

        @errors << 'No se ha insertado el monto del pago por tarjeta.' if invoice.card_paid.zero?

        return if invoice.card_number.present?

        @errors << 'No se ha insertado los digitos de la tarjeta que corresponden a este tipo de pago.'
      end

      def validate_manual_invoice(invoice, company)
        return unless invoice.is_manual

        contingency = invoice.branch_office.point_of_sales.find_by(code: invoice.point_of_sale).contingencies.pending.manual.last
        unless contingency.present?
          @errors << 'No se puede registrar una factura manual sin iniciar previamente una contingencia para la misma.'
        end

        activity_code = invoice.invoice_details.first.economic_activity_code
        economic_activity = company.economic_activities.find_by(code: activity_code)

        cafc = economic_activity.contingency_codes.available.first.present?

        @errors << 'No se puede registrar una factura manual sin codigo CAFC vigente para la Actividad Economica.' unless cafc.present?

        return unless contingency.end_date

        @errors << 'La factura manual debe estar dentro del rango de la contingencia.' if invoice.date.between? contingency.start_date,
                                                                                                                contingency.end_date
      end
    end
  end
end
