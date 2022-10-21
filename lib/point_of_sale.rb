# frozen_string_literal: true

class PointOfSale
  require 'siat_client'

  def self.add(point_of_sale)
    branch_office = point_of_sale.branch_office
    cuis_code = branch_office.cuis_codes.current

    client = SiatClient.client('siat_operations_invoice_wsdl', branch_office.company)

    body = {
      SolicitudRegistroPuntoVenta: {
        codigoAmbiente: branch_office.company.environment_type_id,
        codigoModalidad: branch_office.company.modality_id,
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

    client = SiatClient.client('siat_operations_invoice_wsdl', branch_office.company)

    body = {
      SolicitudCierrePuntoVenta: {
        codigoAmbiente: branch_office.company.environment_type_id,
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
