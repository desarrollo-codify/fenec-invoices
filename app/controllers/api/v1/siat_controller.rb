# frozen_string_literal: true

module Api
  module V1
    # rubocop:disable Metrics/ClassLength
    class SiatController < ApplicationController
      require 'savon'

      before_action :set_branch_office, except: %i[verify_communication]
      before_action :set_cuis_code, except: %i[generate_cuis show_cufd verify_communication]

      def invoice_params
        params.require(:invoice).permit(:business_name, :document_type, :business_nit, :complement, :client_code, :payment_method,
                                        :card_number, :subtotal, :gift_card_total, :discount, :exception_code, :cafc,
                                        :currency_code, :exchange_rate, :currency_total, :user, :document_sector_code,
                                        :cancellation_reason_id, :point_of_sale,
                                        invoice_details_attributes: %i[product_code description quantity measurement_id
                                                                       unit_price discount subtotal serial_number imei_code
                                                                       economic_activity_code])
      end

      def pruebas
        Invoice.destroy_all
        (1..500).each do |i|
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
          @invoice.cafc = nil, # '101993501D57D' # TODO: implement cafc
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
          end

          puts ' '
          puts "#{i}..."
        end
      end

      def process_pending_data(invoice)
        invoice.number = invoice_number
        invoice.cuf = cuf(invoice.date, invoice.number, invoice.control_code, invoice.point_of_sale)
        # TODO: implement paper size: 1 roll, 2 half office or half letter
        invoice.qr_content = qr_content(invoice.company_nit, invoice.cuf, invoice.number, 1)
        invoice.save
      end

      def cuf(invoice_date, invoice_number, control_code, point_of_sale)
        nit = @branch_office.company.nit.rjust(13, '0')
        date = invoice_date.strftime('%Y%m%d%H%M%S%L')
        branch_office = @branch_office.number.to_s.rjust(4, '0')
        modality = '2' # TODO: save modality in company or branch office
        generation_type = '1' # TODO: add generation types for: online, offline and massive
        invoice_type = '1' # TODO: add invoice types table
        sector_document_type = '1'.rjust(2, '0') # TODO: add sector types table
        number = invoice_number.to_s.rjust(10, '0')
        point_of_sale = point_of_sale.to_s.rjust(4, '0') # TODO: implement point of sales for each branch office

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

      def generate_cuis
        client = siat_client('cuis_wsdl')
        body = {
          SolicitudCuis: {
            codigoAmbiente: 2,
            codigoPuntoVenta: 0,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            codigoModalidad: 2,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:cuis, message: body)
        if response.success?
          data = response.to_array(:cuis_response, :respuesta_cuis).first

          code = data[:codigo]
          expiration_date = data[:fecha_vigencia]

          @branch_office.add_cuis_code!(code, expiration_date)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def show_cuis
        if @cuis_code
          render json: @cuis_code.code
        else
          error_message = 'La sucursal no tiene CUIS. Por favor genere uno nuevo.'
          render json: error_message, status: :not_found
        end
      end

      def generate_cufd
        if @cuis_code&.code.blank?
          render json: 'El CUIS no ha sido generado. No es posible generar el CUFD sin ese dato.', status: :unprocessable_entity
          return
        end

        client = siat_client('cuis_wsdl')
        body = {
          SolicitudCufd: {
            codigoAmbiente: 2,
            codigoPuntoVenta: 0,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            codigoModalidad: 2,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:cufd, message: body)
        if response.success?
          data = response.to_array(:cufd_response, :respuesta_cufd).first

          code = data[:codigo]
          control_code = data[:codigo_control]
          end_date = data[:fecha_vigencia]
          @branch_office.add_daily_code!(code, control_code, Date.today, end_date)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def show_cufd
        @daily_code = @branch_office.daily_codes.current
        if @daily_code
          render json: @daily_code.code
        else
          error_message = 'La sucursal no cuenta con un codigo diario CUFD.'
          render json: error_message, status: :not_found
        end
      end

      def siat_product_codes
        client = siat_client('products_wsdl')

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:sincronizar_lista_productos_servicios, message: body)
        if response.success?
          data = response.to_array(:sincronizar_lista_productos_servicios_response, :respuesta_lista_productos, :lista_codigos)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def bulk_products_update; end

      def economic_activities
        client = siat_client('products_wsdl')

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: 0
          }
        }

        response = client.call(:sincronizar_actividades, message: body)
        if response.success?
          data = response.to_array(:sincronizar_actividades_response, :respuesta_lista_actividades, :lista_actividades)

          response_data = data.map do |a|
            a.values_at :codigo_caeb, :descripcion,
                        :tipo_actividad
          end
          activities = response_data.map { |attrs| { code: attrs[0], description: attrs[1], activity_type: attrs[2] } }
          company = @branch_office.company
          company.bulk_load_economic_activities(activities)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def document_types
        client = siat_client('products_wsdl')

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:sincronizar_parametrica_tipo_documento_identidad, message: body)
        if response.success?
          data = response.to_array(:sincronizar_parametrica_tipo_documento_identidad_response, :respuesta_lista_parametricas,
                                   :lista_codigos)

          response_data = data.map do |a|
            a.values_at :codigo_clasificador, :descripcion
          end
          activities = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

          DocumentType.bulk_load(activities)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def payment_methods
        client = siat_client('products_wsdl')

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:sincronizar_parametrica_tipo_metodo_pago, message: body)
        if response.success?
          data = response.to_array(:sincronizar_parametrica_tipo_metodo_pago_response, :respuesta_lista_parametricas,
                                   :lista_codigos)

          response_data = data.map do |a|
            a.values_at :codigo_clasificador, :descripcion
          end
          activities = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

          PaymentMethod.bulk_load(activities)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def legends
        client = siat_client('products_wsdl')

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:sincronizar_lista_leyendas_factura, message: body)
        if response.success?
          data = response.to_array(:sincronizar_lista_leyendas_factura_response, :respuesta_lista_parametricas_leyendas,
                                   :lista_leyendas)
          response_data = data.map do |a|
            a.values_at :codigo_actividad, :descripcion_leyenda
          end
          legends = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

          company = @branch_office.company
          activity_codes = legends.pluck(:code).uniq
          activity_codes.each do |code|
            economic_activity = company.economic_activities.find_by(code: code.to_i)
            activity_legends = legends.select { |l| l[:code] == code }
            economic_activity.bulk_load_legends(activity_legends)
          end

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def measurements
        client = siat_client('products_wsdl')

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:sincronizar_parametrica_unidad_medida, message: body)
        if response.success?
          data = response.to_array(:sincronizar_parametrica_unidad_medida_response, :respuesta_lista_parametricas,
                                   :lista_codigos)

          response_data = data.map do |a|
            a.values_at :codigo_clasificador, :descripcion
          end
          activities = response_data.map { |attrs| { id: attrs[0].to_i, description: attrs[1] } }

          Measurement.bulk_load(activities)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def significative_events
        client = siat_client('products_wsdl')

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:sincronizar_parametrica_eventos_significativos, message: body)
        if response.success?
          data = response.to_array(:sincronizar_parametrica_eventos_significativos_response, :respuesta_lista_parametricas,
                                   :lista_codigos)

          response_data = data.map do |a|
            a.values_at :codigo_clasificador, :descripcion
          end
          events = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

          SignificativeEvent.bulk_load(events)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def verify_communication
        client = siat_client('siat_invoices')

        response = client.call(:verificar_comunicacion)
        if response.success?
          data = response.to_array(:verificar_comunicacion_response).first
          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def pos_types
        client = siat_client('products_wsdl')

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:sincronizar_parametrica_tipo_punto_venta, message: body)
        if response.success?
          data = response.to_array(:sincronizar_parametrica_tipo_punto_venta_response, :respuesta_lista_parametricas,
                                   :lista_codigos)

          response_data = data.map do |a|
            a.values_at :codigo_clasificador, :descripcion
          end
          types = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

          PosType.bulk_load(types)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def cancellation_reasons
        client = siat_client('products_wsdl')

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:sincronizar_parametrica_motivo_anulacion, message: body)
        if response.success?
          data = response.to_array(:sincronizar_parametrica_motivo_anulacion_response, :respuesta_lista_parametricas,
                                   :lista_codigos)

          response_data = data.map do |a|
            a.values_at :codigo_clasificador, :descripcion
          end
          reasons = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

          CancellationReason.bulk_load(reasons)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def document_sectors
        client = siat_client('products_wsdl')

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number,
            codigoPuntoVenta: 0
          }
        }
        response = client.call(:sincronizar_lista_actividades_documento_sector, message: body)

        if response.success?
          data = response.to_array(:sincronizar_lista_actividades_documento_sector_response,
                                   :respuesta_lista_actividades_documento_sector,
                                   :lista_actividades_documento_sector)
          response_data = data.map do |a|
            a.values_at :codigo_actividad, :codigo_documento_sector, :tipo_documento_sector
          end
          document_sectors = response_data.map { |attrs| { activity_code: attrs[0], code: attrs[1], description: attrs[2] } }

          company = @branch_office.company
          activity_codes = document_sectors.pluck(:activity_code).uniq
          activity_codes.each do |activity_code|
            economic_activity = company.economic_activities.find_by(code: activity_code.to_i)
            activity_document_sectors = document_sectors.select { |l| l[:activity_code] == activity_code }
            activity_document_sectors_data = activity_document_sectors.map do |a|
              a.values_at :code, :description
            end
            document_sector_select = activity_document_sectors_data.map { |attrs| { code: attrs[0], description: attrs[1] } }
            economic_activity.bulk_load_document_sectors(document_sector_select)
          end

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def countries
        client = siat_client('products_wsdl')

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:sincronizar_parametrica_pais_origen, message: body)
        if response.success?
          data = response.to_array(:sincronizar_parametrica_pais_origen_response, :respuesta_lista_parametricas,
                                   :lista_codigos)

          response_data = data.map do |a|
            a.values_at :codigo_clasificador, :descripcion
          end
          countries = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

          Country.bulk_load(countries)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def issuance_types
        client = siat_client('products_wsdl')

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:sincronizar_parametrica_tipo_emision, message: body)
        if response.success?
          data = response.to_array(:sincronizar_parametrica_tipo_emision_response, :respuesta_lista_parametricas,
                                   :lista_codigos)

          response_data = data.map do |a|
            a.values_at :codigo_clasificador, :descripcion
          end
          types = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

          IssuanceType.bulk_load(types)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def room_types
        client = siat_client('products_wsdl')

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:sincronizar_parametrica_tipo_habitacion, message: body)
        if response.success?
          data = response.to_array(:sincronizar_parametrica_tipo_habitacion_response, :respuesta_lista_parametricas,
                                   :lista_codigos)

          response_data = data.map do |a|
            a.values_at :codigo_clasificador, :descripcion
          end
          types = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

          RoomType.bulk_load(types)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def currency_types
        client = siat_client('products_wsdl')

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:sincronizar_parametrica_tipo_moneda, message: body)
        if response.success?
          data = response.to_array(:sincronizar_parametrica_tipo_moneda_response, :respuesta_lista_parametricas,
                                   :lista_codigos)

          response_data = data.map do |a|
            a.values_at :codigo_clasificador, :descripcion
          end
          types = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

          CurrencyType.bulk_load(types)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def invoice_types
        client = siat_client('products_wsdl')

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:sincronizar_parametrica_tipos_factura, message: body)
        if response.success?
          data = response.to_array(:sincronizar_parametrica_tipos_factura_response, :respuesta_lista_parametricas,
                                   :lista_codigos)

          response_data = data.map do |a|
            a.values_at :codigo_clasificador, :descripcion
          end
          types = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

          InvoiceType.bulk_load(types)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      private

      def set_branch_office
        @branch_office = BranchOffice.find(params[:branch_office_id])
      end

      def siat_client(wsdl_name)
        Savon.client(
          wsdl: ENV.fetch(wsdl_name.to_s, nil),
          headers: {
            'apikey' => ENV.fetch('api_key', nil),
            'SOAPAction' => ''
          },
          namespace: ENV.fetch('siat_namespace', nil),
          convert_request_keys_to: :none
        )
      end

      def set_cuis_code
        @cuis_code = @branch_office.cuis_codes.current
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
