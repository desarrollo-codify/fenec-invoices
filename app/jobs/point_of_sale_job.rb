# frozen_string_literal: true

class PointOfSaleJob < ApplicationJob
  queue_as :default

  def perform(point_of_sale)
    send_to_siat(point_of_sale)
  end

  def send_to_siat(point_of_sale)
    branch_office = point_of_sale.branch_office
    client = Savon.client(
      wsdl: ENV.fetch('siat_operations', nil),
      headers: {
        'apikey' => ENV.fetch('api_key', nil),
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )

    body = {
      SolicitudRegistroPuntoVenta: {
        codigoAmbiente: 2,
        codigoModalidad: 2,
        codigoSistema: ENV.fetch('system_code', nil),
        codigoSucursal: branch_office.number,
        codigoTipoPuntoVenta: 2,
        cuis: branch_office.cuis_codes.current.code,
        descripcion: point_of_sale.description,
        nombrePuntoVenta: point_of_sale.name,
        nit: branch_office.company.nit.to_i
      }
    }

    response = client.call(:registro_punto_venta, message: body)
    puts response
    # TODO: process all possible scenarios
  end
end
