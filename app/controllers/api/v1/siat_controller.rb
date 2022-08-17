class Api::V1::SiatController < ApplicationController
  require 'savon'

  before_action :set_branch_office, only: %i[generate_cuis]

  def generate_cuis
    client = siat_client('cuis_wsdl')

    body = {
      'SolicitudCuis': {
        'codigoAmbiente': 2,
        'codigoSistema': ENV['system_code'],
        nit: @branch_office.company.nit,
        'codigoModalidad': 2,
        'codigoSucursal': 0
      }
    }
    
    response = client.call(:cuis, message: body)
    if response.success?
      data = response.to_array(:cuis_response, :respuesta_cuis).first

      codigo = data[:codigo]
      @branch_office.update(cuis_number: codigo)

      render json: data
    else
      render json: 'The siat endpoint throwed an error', status: :internal_server_error
    end
  end

  def show_cuis
  end

  def generate_cufd
  end

  def show_cufd
  end

  def siat_product_codes
  end

  def bulk_products_update
  end

  private 

  def set_branch_office
    @branch_office = BranchOffice.find(params[:branch_office_id])
  end

  def siat_client(wsdl_name)
    Savon.client(
      wsdl: ENV[wsdl_name],
      headers: { 
        'apikey' => ENV['api_key'],
        'SOAPAction' => ''
      },
      namespace: ENV['siat_namespace'],
      convert_request_keys_to: :none
    )
  end
end
