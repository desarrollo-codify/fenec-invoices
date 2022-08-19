# frozen_string_literal: true

module Api
  module V1
    class SiatController < ApplicationController
      require 'savon'

      before_action :set_branch_office
      before_action :set_cuis_code

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
        if @cuis_code.code.blank?
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

          @branch_office.add_daily_code!(code, Date.today)

          render json: data
        else
          render json: 'La solicitud a SIAT obtuvo un error.', status: :internal_server_error
        end
      end

      def show_cufd
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

      def load_economic_activities
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

      def load_document_types
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
  end
end
