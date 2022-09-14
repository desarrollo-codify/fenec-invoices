# frozen_string_literal: true

class GenerateCufd
  def self.generate(branch_office, invoice)
    cuis_code = branch_office.cuis_codes.find_by(point_of_sale: invoice.point_of_sale).current.code

    client = Savon.client(
      wsdl: ENV.fetch('cuis_wsdl'.to_s, nil),
      headers: {
        'apikey' => ENV.fetch('api_key', nil),
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )
    body = {
      SolicitudCufd: {
        codigoAmbiente: 2,
        codigoPuntoVenta: invoice.point_of_sale,
        codigoSistema: ENV.fetch('system_code', nil),
        nit: branch_office.company.nit.to_i,
        codigoModalidad: 2,
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
    point_of_sale = invoice.last.point_of_sale
    branch_office.add_daily_code!(code, control_code, Date.today, end_date, point_of_sale)
  end
end
