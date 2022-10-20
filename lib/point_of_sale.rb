# frozen_string_literal: true

class PointOfSale
  def self.add(point_of_sale)
    branch_office = point_of_sale.branch_office
    cuis_code = branch_office.cuis_codes.current
    wsdl = if branch_office.company.environment_type_id == 2 ? 'pilot_siat_operations_invoice_wsdl' : 'siat_operations_invoice_wsdl'
    
    client = Savon.client(
      wsdl: ENV.fetch(wsdl, nil),
      headers: {
        'apikey' => branch_office.company.company_setting.api_key,
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )

    body = {
      SolicitudRegistroPuntoVenta: {
        codigoAmbiente: 2,
        codigoModalidad: 2,
        codigoSistema: branch_office.company.company_setting.system_code,
        codigoSucursal: branch_office.number,
        codigoTipoPuntoVenta: point_of_sale.pos_type_id,
        cuis: cuis_code.code,
        descripcion: point_of_sale.description,
        nombrePuntoVenta: point_of_sale.name,
        nit: branch_office.company.nit.to_i
      }
    }
    response = client.call(:registro_punto_venta, message: body)

    return unless response.success?

    data = response.to_array(:registro_punto_venta_response, :respuesta_registro_punto_venta).first
    transaction = data[:transaccion]
    if transaction
      code = data[:codigo_punto_venta]
      point_of_sale.update(code: code)
    end
    transaction
  end

  def self.destroy(point_of_sale)
    branch_office = point_of_sale.branch_office
    cuis_code = branch_office.cuis_codes.current
    wsdl = if branch_office.company.environment_type_id == 2 ? 'pilot_siat_operations_invoice_wsdl' : 'siat_operations_invoice_wsdl'

    client = Savon.client(
      wsdl: ENV.fetch(wsdl, nil),
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
    data[:transaccion]
  end
end
