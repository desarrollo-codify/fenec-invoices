# frozen_string_literal: true

class VerifyNit
  require 'siat_available'
  require 'siat_client'

  def self.verify(nit, branch_office)
    result = true
    if SiatAvailable.available(branch_office.company.company_setting.api_key)
      cuis_code = branch_office.cuis_codes.where(point_of_sale: 0).current.code

      client = SiatClient.client('siat_codes_invoices_wsdl', branch_office.company)
      body = {
        SolicitudVerificarNit: {
          codigoAmbiente: branch_office.company.environment_type_id,
          codigoSistema: branch_office.company.company_setting.system_code,
          codigoModalidad: branch_office.company.modality_id,
          nit: branch_office.company.nit.to_i,
          cuis: cuis_code,
          codigoSucursal: branch_office.number,
          nitParaVerificacion: nit
        }
      }

      response = client.call(:verificar_nit, message: body)
      return unless response.success?

      data = response.to_array(:verificar_nit_response, :respuesta_verificar_nit, :mensajes_list).first
      description = data[:descripcion]
      result = description == 'NIT ACTIVO'
    else
      result = true
    end
    result
  end
end
