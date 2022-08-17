# frozen_string_literal: true

module Api
  module V1
    class SiatController < ApplicationController
      require 'savon'
      before_action :set_branch_office, only: %i[generate_cuis show_cuis generate_cufd show_cufd siat_product_codes]
      # before_action :set_daily_code, only: %i[generate_cufd]

      def generate_cuis
        client = Savon.client(
          wsdl: 'https://pilotosiatservicios.impuestos.gob.bo/v2/FacturacionCodigos?wsdl',
          headers: {
            'apikey' => 'TokenApi eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJEb21pVXAiLCJjb2RpZ29TaXN0ZW1hIjoiNzIxOUYyOUI2MzExNkNFMDQ2QTc2M0UiLCJuaXQiOiJINHNJQUFBQUFBQUFBRE14TURReXRqQXdNZ01BTGVnQWdna0FBQUE9IiwiaWQiOjMwMTQ3MTksImV4cCI6MTY2NDQ5NjAwMCwiaWF0IjoxNjYwNTc1MjgwLCJuaXREZWxlZ2FkbyI6NDAxMjM4MDI2LCJzdWJzaXN0ZW1hIjoiU0ZFIn0.pAOEdkalOYZrm5G8sYwlv5SNt4H-t1MgGYfz-N3QM73WeHCcYmo8FMHq2GBmSxnsGlNDLx2rb4somiD7S4Gfsg',
            'SOAPAction' => ''
          },
          namespace: 'https://siat.impuestos.gob.bo/',
          convert_request_keys_to: :none
        )

        body = {
          SolicitudCuis: {
            codigoAmbiente: 2,
            codigoSistema: '7219F29B63116CE046A763E',
            nit: 401_238_026,
            codigoModalidad: 2,
            codigoSucursal: 0
          }
        }

        response = client.call(:cuis, message: body)
        if response.success?
          data = response.to_array(:cuis_response, :respuesta_cuis).first

          codigo = data[:codigo]
          @branch_office.update cuis_number: codigo
          render json: data
        else
          render json: 'The siat endpoint throwed an error', status: :internal_server_error
        end
      end

      def show_cuis
        if @branch_office.cuis_number
          render json: @branch_office.cuis_number
        else
          error_message = 'the branch does not have a CUIS code'
          render json: error_message, status: :not_found
        end
      end

      def generate_cufd
        client = Savon.client(
          wsdl: 'https://pilotosiatservicios.impuestos.gob.bo/v2/FacturacionCodigos?wsdl',
          headers: {
            'apikey' => 'TokenApi eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJEb21pVXAiLCJjb2RpZ29TaXN0ZW1hIjoiNzIxOUYyOUI2MzExNkNFMDQ2QTc2M0UiLCJuaXQiOiJINHNJQUFBQUFBQUFBRE14TURReXRqQXdNZ01BTGVnQWdna0FBQUE9IiwiaWQiOjMwMTQ3MTksImV4cCI6MTY2NDQ5NjAwMCwiaWF0IjoxNjYwNTc1MjgwLCJuaXREZWxlZ2FkbyI6NDAxMjM4MDI2LCJzdWJzaXN0ZW1hIjoiU0ZFIn0.pAOEdkalOYZrm5G8sYwlv5SNt4H-t1MgGYfz-N3QM73WeHCcYmo8FMHq2GBmSxnsGlNDLx2rb4somiD7S4Gfsg',
            'SOAPAction' => ''
          },
          namespace: 'https://siat.impuestos.gob.bo/',
          convert_request_keys_to: :none
        )

        body = {
          SolicitudCufd: {
            codigoAmbiente: 2,
            codigoSistema: '7219F29B63116CE046A763E',
            nit: 401_238_026,
            codigoModalidad: 2,
            cuis: @branch_office.cuis_number,
            codigoSucursal: 0
          }
        }

        response = client.call(:cufd, message: body)
        if response.success?
          data = response.to_array(:cufd_response, :respuesta_cufd).first

          codigo = data[:codigo]

          @daily_code = @branch_office.daily_codes.build(code: codigo, effective_date: '2022-08-16')
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
        client = Savon.client(
          wsdl: 'https://pilotosiatservicios.impuestos.gob.bo/v2/FacturacionSincronizacion?wsdl',
          headers: {
            'apikey' => 'TokenApi eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJEb21pVXAiLCJjb2RpZ29TaXN0ZW1hIjoiNzIxOUYyOUI2MzExNkNFMDQ2QTc2M0UiLCJuaXQiOiJINHNJQUFBQUFBQUFBRE14TURReXRqQXdNZ01BTGVnQWdna0FBQUE9IiwiaWQiOjMwMTQ3MTksImV4cCI6MTY2NDQ5NjAwMCwiaWF0IjoxNjYwNTc1MjgwLCJuaXREZWxlZ2FkbyI6NDAxMjM4MDI2LCJzdWJzaXN0ZW1hIjoiU0ZFIn0.pAOEdkalOYZrm5G8sYwlv5SNt4H-t1MgGYfz-N3QM73WeHCcYmo8FMHq2GBmSxnsGlNDLx2rb4somiD7S4Gfsg',
            'SOAPAction' => ''
          },
          namespace: 'https://siat.impuestos.gob.bo/',
          convert_request_keys_to: :none
        )

        body = {
          SolicitudSincronizacion: {
            codigoAmbiente: 2,
            codigoSistema: '7219F29B63116CE046A763E',
            nit: 401_238_026,
            cuis: @branch_office.cuis_number,
            codigoSucursal: 0
          }
        }

        response = client.call(:sincronizar_lista_productos_servicios, message: body)
        if response.success?
          data = response.to_array(:sincronizar_lista_productos_servicios_response,
                                   :respuesta_sincronizar_lista_productos_servicios).first

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

      # def set_daily_code
      #   @daily_code = DailyCode.find(params[:id])
      # end
    end
  end
end
