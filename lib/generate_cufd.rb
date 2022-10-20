# frozen_string_literal: true

class GenerateCufd
  require 'siat_client'

  def self.generate(point_of_sale)
    branch_office = point_of_sale.branch_office
    company = branch_office.company
    cuis_code = branch_office.cuis_codes.where(point_of_sale: point_of_sale.code).current.code

    client = SiatClient.client('siat_codes_invoices_wsdl', company)
    body = {
      SolicitudCufd: {
        codigoAmbiente: company.environment_type_id,
        codigoPuntoVenta: point_of_sale.code,
        codigoSistema: company.company_setting.system_code,
        nit: company.nit.to_i,
        codigoModalidad: company.modality_id,
        cuis: cuis_code,
        codigoSucursal: branch_office.number
      }
    }

    response = client.call(:cufd, message: body)
    return unless response.success?

    data = response.to_array(:cufd_response, :respuesta_cufd).first

    code = data[:codigo]
    control_code = data[:codigo_control]
    end_date = data[:fecha_vigencia]
    branch_office.add_daily_code!(code, control_code, DateTime.now, end_date, point_of_sale.code)
  end
end
