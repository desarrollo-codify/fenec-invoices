# frozen_string_literal: true

module Api
  module V1
    # rubocop:disable Metrics/ClassLength
    class SiatController < ApplicationController
      require 'savon'

      before_action :set_branch_office
      before_action :set_cuis_code, except: %i[generate_cuis show_cufd]

      def pruebas
        @branch_office = BranchOffice.first
        (1..10).each do |_i|
          client = siat_client('cuis_wsdl')
          body = {
            SolicitudCufd: {
              codigoAmbiente: 2,
              codigoSistema: ENV.fetch('system_code', nil),
              nit: @branch_office.company.nit.to_i,
              codigoModalidad: 2,
              cuis: 'BF840B24',
              codigoSucursal: @branch_office.number,
              codigoPuntoVenta: 0
            }
          }

          response = client.call(:cufd, message: body)
          next unless response.success?

          data = response.to_array(:cufd_response, :respuesta_cufd).first

          code = data[:codigo]
          control_code = data[:codigo_control]
          @branch_office.add_daily_code!(code, control_code, Date.today)

          (1..12).each do |j|
          end
        end
      end

      def generate_cuis
        client = siat_client('cuis_wsdl')
        body = {
          SolicitudCuis: {
            codigoAmbiente: 2,
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
          @branch_office.add_daily_code!(code, control_code, Date.today)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def show_cufd
        @daily_code = @branch_office.daily_codes.last
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
        @cuis_code = @branch_office.cuis_codes.last
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
