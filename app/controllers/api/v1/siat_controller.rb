# frozen_string_literal: true

module Api
  module V1
    class SiatController < ApplicationController
      require 'savon'

      before_action :set_branch_office, only: %i[generate_cuis show_cuis generate_cufd show_cufd siat_product_codes]

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
          render json: 'The siat endpoint throwed an error', status: :internal_server_error
        end
      end

      def show_cuis
        if @branch_office.cuis_codes.last
          render json: @branch_office.cuis_codes.code
        else
          error_message = 'La sucursal no tiene CUIS. Por favor genere uno nuevo.'
          render json: error_message, status: :not_found
        end
      end

      def generate_cufd
        if @branch_office.cuis_codes.code.blank?
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
            cuis: @branch_office.cuis_codes.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:cufd, message: body)
        if response.success?
          data = response.to_array(:cufd_response, :respuesta_cufd).first

          code = data[:codigo]

          @daily_code = @branch_office.daily_codes.build(code: code, effective_date: '2022-08-16')
          if @daily_code.save
            render json: data
          else
            render json: @daily_code.errors, status: :unprocessable_entity
          end
        else
          render json: 'The siat endpoint throwed an error', status: :internal_server_error
        end
      end

      def show_cufd
        @daily_code = @branch_office.daily_codes.first
        if @daily_code.code
          render json: @daily_code.code
        else
          error_message = 'the branch does not have a CUFD code'
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
            cuis: @branch_office.cuis_codes.code,
            codigoSucursal: @branch_office.number
          }
        }

        response = client.call(:sincronizar_lista_productos_servicios, message: body)
        if response.success?
          data = response.to_array(:sincronizar_lista_productos_servicios_response, :respuesta_lista_productos, :lista_codigos)

          render json: data
        else
          render json: 'The siat endpoint throwed an error', status: :internal_server_error
        end
      end

      def bulk_products_update; end

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
    end
  end
end
