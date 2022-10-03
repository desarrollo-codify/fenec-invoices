class PointOfSaleDestroyJob < ApplicationJob
  queue_as :default

  def perform(point_of_sale)
    send_to_siat(point_of_sale)
  end

  def send_to_siat(point_of_sale)
    branch_office = point_of_sale.branch_office
    cuis_code = branch_office.cuis_codes.where('point_of_sale = ?', params[:point_of_sale]).current
    client = Savon.client(
      wsdl: ENV.fetch('siat_operations', nil),
      headers: {
        'apikey' => branch_office.company.company_setting.api_key,
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )

    body = {
      SolicitudCierrePuntoVenta: {
        codigoAmbiente: 2,
        codigoSistema: branch_office.company.company_setting.system_code,
        codigoSucursal: branch_office.number,
        cuis: cuis_code.code,
        nit: branch_office.company.nit.to_i,
        codigoPuntoVenta: point_of_sale.code
      }
    }

    response = client.call(:cierre_punto_venta, message: body)
    return unless response.success?

    data = response.to_array(:cierre_punto_venta_response, :respuesta_cierre_punto_venta).first
    transaction = data[:transaccion]
    return unless transaction

    code = data[:codigo_punto_venta]
    point_of_sale.destroy
  end
end
