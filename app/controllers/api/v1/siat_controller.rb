class Api::V1::SiatController < ApplicationController
  require 'savon'

  before_action :set_branch_office, only: %i[generate_cuis]

  def generate_cuis
    client = Savon.client(
      wsdl: 'https://pilotosiatservicios.impuestos.gob.bo/v2/FacturacionCodigos?wsdl',
      headers: { 
        'apikey' => 'TokenApi eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJEb21pVXAiLCJjb2RpZ29TaXN0ZW1hIjoiNzIxOUYyOUI2MzExNkNFMDQ2QTc2M0UiLCJuaXQiOiJINHNJQUFBQUFBQUFBRE14TURReXRqQXdNZ01BTGVnQWdna0FBQUE9IiwiaWQiOjMwMTQ3MTksImV4cCI6MTY2NDQ5NjAwMCwiaWF0IjoxNjYwNTc1MjgwLCJuaXREZWxlZ2FkbyI6NDAxMjM4MDI2LCJzdWJzaXN0ZW1hIjoiU0ZFIn0.pAOEdkalOYZrm5G8sYwlv5SNt4H-t1MgGYfz-N3QM73WeHCcYmo8FMHq2GBmSxnsGlNDLx2rb4somiD7S4Gfsg',
        'SOAPAction' => ''
      },
      namespace: "https://siat.impuestos.gob.bo/",
      convert_request_keys_to: :none
    )

    body = {
      'SolicitudCuis': {
        'codigoAmbiente': 2,
        'codigoSistema': '7219F29B63116CE046A763E',
        nit: 401238026,
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
end
