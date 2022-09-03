# frozen_string_literal: true

module Api
  module V1
    class ContingenciesController < ApplicationController
      before_action :set_contingency, only: %i[show close update destroy]
      before_action :set_branch_office, only: %i[index create]
      # GET /api/v1/contingencies
      def index
        @contingencies = branch_office.contingencies

        render json: @contingencies
      end

      # GET /api/v1/contingencies/1
      def show
        render json: @contingency
      end

      # POST /api/v1/branch_office/:branch_office_id/contingencies
      def create
        @contingency = @branch_office.contingencies.build(contingency_params)

        if @contingency.save
          render json: @contingency, status: :created
        else
          render json: @contingency.errors, status: :unprocessable_entity
        end
      end

      # POST api/v1/contingencies/:contingency_id/close
      def close
        @contingency.close!
        
        if @contingency.save
          Contingency.perform_now(@contingency)
          reception_validation(@contingency)
          render json: @contingency, status: :created
        else
          render json: @contingency.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/contingencies/1
      def update
        if @contingency.update(contingency_params)
          render json: @contingency
        else
          render json: @contingency.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/contingencies/1
      def destroy
        @contingency.destroy
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_contingency
        @contingency = Contingency.find(params[:id])
      end

      def set_branch_office
        @branch_office = BranchOffice.find(params[:branch_office_id])
      end

      # Only allow a list of trusted parameters through.
      def contingency_params
        params.require(:contingency).permit(:start_date, :end_date, :significative_event_id)
      end

      def reception_validation(contingency)
        cuis_code = contingency.branch_offices.cuis_codes.last
        cufd_code = contingency.branch_offices.daily_codes.last
        client =Savon.client(
          wsdl: ENV.fetch('siat_invoices'.to_s, nil),
          headers: {
            'apikey' => ENV.fetch('api_key', nil),
            'SOAPAction' => ''
          },
          namespace: ENV.fetch('siat_namespace', nil),
          convert_request_keys_to: :none
        )
    
        body = {
          SolicitudServicioValidacionRecepcionPaquete: {
            codigoAmbiente: 2,
            codigoSistema: ENV.fetch('system_code', nil),
            codigoSucursal: branch_office.number,
            nit: branch_office.company.nit.to_i,
            codigoDocumentoSector: 1
            codigoEmision: 2
            codigoModalidad: 2
            cufd: cufd_code.code,
            cuis: cuis_code.code,
            tipoFacturaDocumento: 1
            codigoRecepcion: contingency.reception_code
          }
        }
        response = client.call(:validacion_recepcion_paquete_factura, message: body)
        if response.success?
          data = response.to_array(:validacion_recepcion_paquete_factura_response, :respuesta_servicio_facturacion , :mensajes_list)
          data = data[:codigoEstado]
        else
          data = {return: 'communication error'}
        end
        if data == '908'
          data = 'valid'
        else 
          if data == '904'
            data = 'observed'
          else
            data = 'pending' if data == '901'
        end
      end
    end
  end
end
