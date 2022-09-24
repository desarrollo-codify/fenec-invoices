# frozen_string_literal: true

module Api
  module V1
    class SiatController < ApplicationController
      require 'savon'
      require 'verify_nit'

      before_action :set_branch_office, except: %i[verify_communication]
      before_action :set_cuis_code, except: %i[generate_cuis show_cufd verify_communication]
      before_action :set_cuis_code_default, except: %i[generate_cuis show_cufd show_cuis generate_cufd verify_communication]

      def generate_cuis
        @company = @branch_office.company
        client = siat_client('cuis_wsdl')
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
        if response.success?
          data = response.to_array(:cuis_response, :respuesta_cuis).first

          code = data[:codigo]
          expiration_date = data[:fecha_vigencia]

          @branch_office.add_cuis_code!(code, expiration_date, params[:point_of_sale])

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
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
        client = siat_client('cuis_wsdl')
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
        if response.success?
          data = response.to_array(:cufd_response, :respuesta_cufd).first

          code = data[:codigo]
          control_code = data[:codigo_control]
          end_date = data[:fecha_vigencia]
          @branch_office.add_daily_code!(code, control_code, Date.today, end_date, params[:point_of_sale])

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def show_cufd
        @daily_code = @branch_office.daily_codes.where(point_of_sale: params[:point_of_sale]).current
        if @daily_code.present?
          render json: @daily_code
        else
          error_message = 'La sucursal no cuenta con un codigo diario CUFD.'
          render json: error_message, status: :not_found
        end
      end

      def product_codes
        client = siat_client('products_wsdl')
        company = @branch_office.company

        response = client.call(:sincronizar_lista_productos_servicios, message: siat_body)
        if response.success?
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
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def economic_activities
        client = siat_client('products_wsdl')

        response = client.call(:sincronizar_actividades, message: siat_body)
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

        response = client.call(:sincronizar_parametrica_tipo_documento_identidad, message: siat_body)
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

        response = client.call(:sincronizar_parametrica_tipo_metodo_pago, message: siat_body)
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

        response = client.call(:sincronizar_lista_leyendas_factura, message: siat_body)
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

        response = client.call(:sincronizar_parametrica_unidad_medida, message: siat_body)
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

        response = client.call(:sincronizar_parametrica_eventos_significativos, message: siat_body)
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

        response = client.call(:sincronizar_parametrica_tipo_punto_venta, message: siat_body)
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

        response = client.call(:sincronizar_parametrica_motivo_anulacion, message: siat_body)
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

        response = client.call(:sincronizar_lista_actividades_documento_sector, message: siat_body)

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

        response = client.call(:sincronizar_parametrica_pais_origen, message: siat_body)
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

        response = client.call(:sincronizar_parametrica_tipo_emision, message: siat_body)
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

        response = client.call(:sincronizar_parametrica_tipo_habitacion, message: siat_body)
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

        response = client.call(:sincronizar_parametrica_tipo_moneda, message: siat_body)
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

        response = client.call(:sincronizar_parametrica_tipos_factura, message: siat_body)
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

      def service_messages
        client = siat_client('products_wsdl')

        response = client.call(:sincronizar_lista_mensajes_servicios, message: siat_body)
        if response.success?
          data = response.to_array(:sincronizar_lista_mensajes_servicios_response, :respuesta_lista_parametricas,
                                   :lista_codigos)

          response_data = data.map do |a|
            a.values_at :codigo_clasificador, :descripcion
          end
          types = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

          ServiceMessage.bulk_load(types)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def document_sector_types
        client = siat_client('products_wsdl')

        response = client.call(:sincronizar_parametrica_tipo_documento_sector, message: siat_body)
        if response.success?
          data = response.to_array(:sincronizar_parametrica_tipo_documento_sector_response, :respuesta_lista_parametricas,
                                   :lista_codigos)

          response_data = data.map do |a|
            a.values_at :codigo_clasificador, :descripcion
          end
          types = response_data.map { |attrs| { code: attrs[0], description: attrs[1] } }

          DocumentSectorType.bulk_load(types)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def verify_nit
        response = VerifyNit.verify(params[:nit], @branch_office)

        render json: response
      end

      private

      def set_branch_office
        @branch_office = BranchOffice.find(params[:branch_office_id])
        @company = @branch_office.company
      end

      def siat_client(wsdl_name)
        Savon.client(
          wsdl: ENV.fetch(wsdl_name.to_s, nil),
          headers: {
            'apikey' => @company.company_setting.api_key,
            'SOAPAction' => ''
          },
          namespace: ENV.fetch('siat_namespace', nil),
          convert_request_keys_to: :none
        )
      end

      def set_cuis_code
        @cuis_code = @branch_office.cuis_codes.where('point_of_sale = ?', params[:point_of_sale]).current
      end

      def set_cuis_code_default
        @cuis_code = @branch_office.cuis_codes.where(point_of_sale: 0).current
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
