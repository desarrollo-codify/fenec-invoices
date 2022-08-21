# frozen_string_literal: true

module Api
  module V1
    class InvoicesController < ApplicationController
      before_action :set_invoice, only: %i[show update destroy]
      before_action :set_branch_office, only: %i[index create generate_invoice]

      # GET /api/v1/invoices
      def index
        @invoices = @branch_office.invoices # or company?

        render json: @invoices
      end

      # GET /api/v1/invoices/1
      def show
        render json: @invoice
      end

      # POST /api/v1/invoices
      def create
        @invoice = @branch_office.invoices.build(invoice_params)

        

        if @invoice.save
          @cuis_code = @branch_office.cuis_codes.last
          @current_number = @cuis_code.current_number
          @cuis_code.update(current_number: @current_number + 1)
          
          render json: @invoice, status: :created
        else
          render json: @invoice.errors, status: :unprocessable_entity
        end
      end

      def generate_invoice
        @cuis_code = @branch_office.cuis_codes.last
        @daily_code = @branch_office.daily_code.last
        
        @company = @branch_office.company
        #hay que verlo
        @client = @company.clients.find(params[:client_id])
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.facturaComputarizadaCompraVenta xsi:noNamespaceSchemaLocation="facturaComputarizadaCompraVenta.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"{
            xml.cabecera {
              xml.nitEmisor @invoice.business_nit
              xml.razonSocialEmisor @invoice.business_name
              xml.municipio @invoice.municipality
              xml.telefono @invoice.branch_office.phone
              xml.numeroFactura @cuis_code.current_number
              xml.cuf "123134564789" #hacer algoritmo
              xml.cufd @daily_code.code
              xml.codigoSucursal @invoice.branch_office.number
              xml.direccion @invoice.branch_office.address
              xml.codigoPuntoVenta xsi:nil="true"
              xml.fechaEmision @invoice.date
              xml.nombreRazonSocial @invoice.company_name
              xml.codigoTipoDocumentoIdentidad 1 #@invoice.document_type.code
              xml.numeroDocumento @invoice.company_nit
              xml.complemento xsi:nil="true"
              xml.codigoCliente "1"
              xml.codigoMetodoPago "1" #@invoice.payment_method.code
              xml.montoTotal @invoice.total
              xml.montoTotalSujetoIva @invoice.subtotal
              xml.codigoMoneda @invoice.currency_code
              xml.tipoCambio @invoice.exchange_rate
              xml.montoTotalMoneda @invoice.total #revisar
              xml.montoGiftCard @invoice.gift_card
              xml.descuentoAdicional @invoice.discount
              xml.codigoExcepcion @invoice.exception_code
              xml.cafc xsi:nil="true"
              xml.leyenda @invoice.legends.description
              xml.usuario @invoice.user
              xml.codigoDocumentoSector "1" #revisar
            }
            xml.detalle {
              xml.actividadEconomica @invoice.invoice_details.activity_type
              xml.codigoProductoSin "49111" #revisar
              xml.codigoProducto @invoice.invoice_details.product_code
              xml.descripcion @invoice.invoice_details.description
              xml.cantidad @invoice.invoice_details.quantity
              xml.unidadMedida @invoice.invoice_details.measurement_id
              xml.precioUnitario @invoice.invoice_details.unit_price
              xml.montoDescuento @invoice.invoice_details.discount
              xml.subTotal @invoice.invoice_details.subtotal
              xml.numeroSerie "123"
              xml.numeroImei "123"
            }
          }
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
        # TODO: refactor this for unnecessary params when creating, like cancellation_date
        # TODO: add strong params for details
        # params.require(:invoice).permit(:number, :date, :company_name, :company_nit, :business_name, :business_nit,
        #                                 :authorization, :key, :end_date, :activity_type, :control_code, :qr_content,
        #                                 :subtotal, :discount, :gift_card, :advance, :total, :cash_paid, :qr_paid,
        #                                 :card_paid, :online_paid, :change, :cancellation_date, :exchange_rate,
        #                                 :cuis_code, :cufd_code, :invoice_status_id)
        params.require(:invoice).permit(:business_name, :business_nit, :municipality, :number, :key, :cufd_code
                                        :date, :company_name, :company_nit, :complement, :total, :subtotal, :gift_card,
                                        :discount, :exception_code, :authorization, :currency_code, :exchange_rate, :user,
                                        :qr_paid, :card_paid, :online_paid, :cash_paid, :change, :cancellation_date,
                                        :invoice_status_id, :invoice_details: [
                                          :economic_activity, :product_code, :description, :quantity, :measurement_id, 
                                          :unit_price, :discount, :subtotal
                                        ])
      end
    end
  end
end
