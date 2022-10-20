# frozen_string_literal: true

module Api
  module V1
    class SiatController < ApplicationController
      require 'savon'
      require 'siat_available'
      require 'verify_nit'
      require 'siat_client'

      before_action :set_branch_office, except: %i[verify_communication]
      before_action :set_cuis_code, except: %i[generate_cuis show_cufd verify_communication]
      before_action :set_cuis_code_default, except: %i[generate_cuis show_cufd show_cuis generate_cufd verify_communication]
      before_action :set_siat_available, except: %i[show_cufd show_cuis verify_nit verify_communication]

      def generate_cuis
        @company = @branch_office.company
        client = SiatClient.client('siat_codes_invoices_wsdl', @company)
        body = {
          SolicitudCuis: {
            codigoAmbiente: 2,
            codigoPuntoVenta: params[:point_of_sale],
            codigoSistema: @company.company_setting.system_code,
            nit: @company.nit.to_i,
            codigoModalidad: 2,
            codigoSucursal: @branch_office.number
          }
        }
        response = client.call(:cuis, message: body)
        data = response.to_array(:cuis_response, :respuesta_cuis).first

        if !data[:transaccion] && data[:mensajes_list][:codigo] != '980'
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{data[:mensajes_list][:descripcion]}"
        end

        code = data[:codigo]
        expiration_date = data[:fecha_vigencia]

        @branch_office.add_cuis_code!(code, expiration_date, params[:point_of_sale])

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def show_cuis
        if @cuis_code
          render json: @cuis_code
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

        @company = @branch_office.company
        client = SiatClient.client('siat_codes_invoices_wsdl', @company)
        body = {
          SolicitudCufd: {
            codigoAmbiente: 2,
            codigoPuntoVenta: params[:point_of_sale],
            codigoSistema: @company.company_setting.system_code,
            nit: @company.nit.to_i,
            codigoModalidad: 2,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:cufd, message: body)
        data = response.to_array(:cufd_response, :respuesta_cufd).first

        unless data[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{data[:mensajes_list][:descripcion]}"
        end

        code = data[:codigo]
        control_code = data[:codigo_control]
        end_date = data[:fecha_vigencia]
        @branch_office.add_daily_code!(code, control_code, DateTime.now, end_date, params[:point_of_sale])

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def show_cufd
        @daily_code = @branch_office.daily_codes.by_pos(params[:point_of_sale]).current
        if @daily_code.present?
          render json: @daily_code
        else
          error_message = 'La sucursal no cuenta con un codigo diario CUFD.'
          render json: error_message, status: :not_found
        end
      end

      def product_codes
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)
        company = @branch_office.company

        response = client.call(:sincronizar_lista_productos_servicios, message: siat_body)
        response_transaction = response.to_array(:sincronizar_lista_productos_servicios_response, :respuesta_lista_productos).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:sincronizar_lista_productos_servicios_response, :respuesta_lista_productos, :lista_codigos)
        response_data = data.map do |a|
          a.values_at :codigo_actividad, :codigo_producto, :descripcion_producto
        end
        products = response_data.map { |attrs| { activity_code: attrs[0], code: attrs[1], description: attrs[2] } }

        company = @branch_office.company
        activity_codes = products.pluck(:activity_code).uniq
        activity_codes.each do |activity_code|
          economic_activity = company.economic_activities.find_by(code: activity_code.to_i)
          activity_products = products.select { |l| l[:activity_code] == activity_code }
          activity_products_data = activity_products.uniq { |p| p[:code] }.map do |a|
            a.values_at :code, :description
          end
          products_select = activity_products_data.map { |attrs| { code: attrs[0], description: attrs[1] } }
          economic_activity.bulk_load_product_codes(products_select)
        end
        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def economic_activities
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_actividades, message: siat_body)

        response_transaction = response.to_array(:sincronizar_actividades_response, :respuesta_lista_actividades).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:sincronizar_actividades_response, :respuesta_lista_actividades, :lista_actividades)
        response_data = data.map do |a|
          a.values_at :codigo_caeb, :descripcion,
                      :tipo_actividad
        end
        activities = response_data.map { |attrs| { code: attrs[0], description: attrs[1], activity_type: attrs[2] } }
        company = @branch_office.company
        company.bulk_load_economic_activities(activities)

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def document_types
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_parametrica_tipo_documento_identidad, message: siat_body)

        response_transaction = response.to_array(:sincronizar_parametrica_tipo_documento_identidad_response,
                                                 :respuesta_lista_parametricas).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:sincronizar_parametrica_tipo_documento_identidad_response, :respuesta_lista_parametricas,
                                 :lista_codigos)
        response_data = data.map do |a|
          a.values_at :codigo_clasificador, :descripcion
        end
        activities = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

        DocumentType.bulk_load(activities)

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def payment_methods
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_parametrica_tipo_metodo_pago, message: siat_body)

        response_transaction = response.to_array(:sincronizar_parametrica_tipo_metodo_pago_response,
                                                 :respuesta_lista_parametricas).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:sincronizar_parametrica_tipo_metodo_pago_response, :respuesta_lista_parametricas,
                                 :lista_codigos)
        response_data = data.map do |a|
          a.values_at :codigo_clasificador, :descripcion
        end
        activities = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

        PaymentMethod.bulk_load(activities)

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def legends
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_lista_leyendas_factura, message: siat_body)
        response_transaction = response.to_array(:sincronizar_lista_leyendas_factura_response,
                                                 :respuesta_lista_parametricas_leyendas).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

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
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def measurements
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_parametrica_unidad_medida, message: siat_body)

        response_transaction = response.to_array(:sincronizar_parametrica_unidad_medida_response,
                                                 :respuesta_lista_parametricas).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:sincronizar_parametrica_unidad_medida_response, :respuesta_lista_parametricas,
                                 :lista_codigos)

        response_data = data.map do |a|
          a.values_at :codigo_clasificador, :descripcion
        end
        activities = response_data.map { |attrs| { id: attrs[0].to_i, description: attrs[1] } }

        Measurement.bulk_load(activities)

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def significative_events
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_parametrica_eventos_significativos, message: siat_body)

        response_transaction = response.to_array(:sincronizar_parametrica_eventos_significativos_response,
                                                 :respuesta_lista_parametricas).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:sincronizar_parametrica_eventos_significativos_response, :respuesta_lista_parametricas,
                                 :lista_codigos)

        response_data = data.map do |a|
          a.values_at :codigo_clasificador, :descripcion
        end
        events = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

        SignificativeEvent.bulk_load(events)

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def verify_communication
        @company = Company.first

        client = SiatClient.client('siat_computarized_invoice_service_wsdl', @company)

        response = client.call(:verificar_comunicacion)

        data = response.to_array(:verificar_comunicacion_response).first

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def pos_types
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_parametrica_tipo_punto_venta, message: siat_body)

        response_transaction = response.to_array(:sincronizar_parametrica_tipo_punto_venta_response,
                                                 :respuesta_lista_parametricas).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:sincronizar_parametrica_tipo_punto_venta_response, :respuesta_lista_parametricas,
                                 :lista_codigos)

        response_data = data.map do |a|
          a.values_at :codigo_clasificador, :descripcion
        end
        types = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

        PosType.bulk_load(types)

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def cancellation_reasons
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_parametrica_motivo_anulacion, message: siat_body)

        response_transaction = response.to_array(:sincronizar_parametrica_motivo_anulacion_response,
                                                 :respuesta_lista_parametricas).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:sincronizar_parametrica_motivo_anulacion_response, :respuesta_lista_parametricas,
                                 :lista_codigos)

        response_data = data.map do |a|
          a.values_at :codigo_clasificador, :descripcion
        end
        reasons = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

        CancellationReason.bulk_load(reasons)

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def document_sectors
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_lista_actividades_documento_sector, message: siat_body)

        response_transaction = response.to_array(:sincronizar_lista_actividades_documento_sector_response,
                                                 :respuesta_lista_actividades_documento_sector).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

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
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def countries
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_parametrica_pais_origen, message: siat_body)

        response_transaction = response.to_array(:sincronizar_parametrica_pais_origen_response, :respuesta_lista_parametricas).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:sincronizar_parametrica_pais_origen_response, :respuesta_lista_parametricas,
                                 :lista_codigos)

        response_data = data.map do |a|
          a.values_at :codigo_clasificador, :descripcion
        end
        countries = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

        Country.bulk_load(countries)

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def issuance_types
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_parametrica_tipo_emision, message: siat_body)

        response_transaction = response.to_array(:sincronizar_parametrica_tipo_emision_response,
                                                 :respuesta_lista_parametricas).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:sincronizar_parametrica_tipo_emision_response, :respuesta_lista_parametricas,
                                 :lista_codigos)

        response_data = data.map do |a|
          a.values_at :codigo_clasificador, :descripcion
        end
        types = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

        IssuanceType.bulk_load(types)

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def room_types
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_parametrica_tipo_habitacion, message: siat_body)

        response_transaction = response.to_array(:sincronizar_parametrica_tipo_habitacion_response,
                                                 :respuesta_lista_parametricas).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:sincronizar_parametrica_tipo_habitacion_response, :respuesta_lista_parametricas,
                                 :lista_codigos)

        response_data = data.map do |a|
          a.values_at :codigo_clasificador, :descripcion
        end
        types = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

        RoomType.bulk_load(types)

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def currency_types
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_parametrica_tipo_moneda, message: siat_body)

        response_transaction = response.to_array(:sincronizar_parametrica_tipo_moneda_response, :respuesta_lista_parametricas).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:sincronizar_parametrica_tipo_moneda_response, :respuesta_lista_parametricas,
                                 :lista_codigos)

        response_data = data.map do |a|
          a.values_at :codigo_clasificador, :descripcion
        end
        types = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

        CurrencyType.bulk_load(types)

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def invoice_types
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_parametrica_tipos_factura, message: siat_body)

        response_transaction = response.to_array(:sincronizar_parametrica_tipos_factura_response,
                                                 :respuesta_lista_parametricas).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:sincronizar_parametrica_tipos_factura_response, :respuesta_lista_parametricas,
                                 :lista_codigos)

        response_data = data.map do |a|
          a.values_at :codigo_clasificador, :descripcion
        end
        types = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

        InvoiceType.bulk_load(types)

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def service_messages
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_lista_mensajes_servicios, message: siat_body)

        response_transaction = response.to_array(:sincronizar_lista_mensajes_servicios_response,
                                                 :respuesta_lista_parametricas).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:sincronizar_lista_mensajes_servicios_response, :respuesta_lista_parametricas,
                                 :lista_codigos)

        response_data = data.map do |a|
          a.values_at :codigo_clasificador, :descripcion
        end
        types = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

        ServiceMessage.bulk_load(types)

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def document_sector_types
        client = SiatClient.client('siat_sync_invoice_wsdl', @company)

        response = client.call(:sincronizar_parametrica_tipo_documento_sector, message: siat_body)

        response_transaction = response.to_array(:sincronizar_parametrica_tipo_documento_sector_response,
                                                 :respuesta_lista_parametricas).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:sincronizar_parametrica_tipo_documento_sector_response, :respuesta_lista_parametricas,
                                 :lista_codigos)

        response_data = data.map do |a|
          a.values_at :codigo_clasificador, :descripcion
        end
        types = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

        DocumentSectorType.bulk_load(types)

        render json: data
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def verify_nit
        nit = params[:nit]
        client = SiatClient.client('siat_codes_invoices_wsdl', @company)
        body = {
          SolicitudVerificarNit: {
            codigoAmbiente: 2,
            codigoSistema: @branch_office.company.company_setting.system_code,
            codigoModalidad: 2,
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number,
            nitParaVerificacion: nit
          }
        }

        response = client.call(:verificar_nit, message: body)

        response_transaction = response.to_array(:verificar_nit_response, :respuesta_verificar_nit).first

        if !response_transaction[:transaccion] && response_transaction[:mensajes_list][:codigo] != '994'
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data = response.to_array(:verificar_nit_response, :respuesta_verificar_nit, :mensajes_list).first

        description = data[:descripcion]
        result = description == 'NIT ACTIVO'

        render json: result
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def point_of_sales
        client = SiatClient.client('siat_operations_invoice_wsdl', @company)
        body = {
          SolicitudConsultaPuntoVenta: {
            codigoAmbiente: 2,
            codigoSistema: @branch_office.company.company_setting.system_code,
            codigoSucursal: @branch_office.number,
            cuis: @cuis_code.code,
            nit: @branch_office.company.nit.to_i
          }
        }

        response = client.call(:consulta_punto_venta, message: body)

        response_transaction = response.to_array(:consulta_punto_venta_response, :respuesta_consulta_punto_venta).first

        unless response_transaction[:transaccion]
          return render json: "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
        end

        data_pos = response.to_array(:consulta_punto_venta_response, :respuesta_consulta_punto_venta, :lista_puntos_ventas)

        response_data = data_pos.map do |a|
          a.values_at :codigo_punto_venta, :nombre_punto_venta, :tipo_punto_venta
        end

        pos_list = response_data.map do |attrs|
          { code: attrs[0], name: attrs[1], pos_type_id: PosType.find_by(description: attrs[2]).id }
        end

        @branch_office.add_point_of_sales!(pos_list)

        render json: pos_list
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      private

      def set_branch_office
        @branch_office = BranchOffice.find(params[:branch_office_id])
        @company = @branch_office.company
      end

      def set_siat_available
        data = SiatAvailable.available(@branch_office.company.company_setting.api_key)
        return if data

        render json: 'La solicitud a SIAT no se pudo procesar, intente nuevamente en unos minutos.',
               status: :precondition_failed
      rescue StandardError => e
        render json: "La solicitud a SIAT obtuvo el siguiente error: #{e}", status: :internal_server_error
      end

      def set_cuis_code
        @cuis_code = @branch_office.cuis_codes.by_pos(params[:point_of_sale]).current
      end

      def set_cuis_code_default
        @cuis_code = @branch_office.cuis_codes.by_pos(0).current
      end

      def siat_body
        {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: @branch_office.company.company_setting.system_code,
            nit: @branch_office.company.nit.to_i,
            cuis: @cuis_code.code,
            codigoSucursal: @branch_office.number
          }
        }
      end
    end
  end
end
