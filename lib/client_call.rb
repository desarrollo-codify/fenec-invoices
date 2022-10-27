# frozen_string_literal: true

class ClientCall
  require 'savon'
  require 'siat_client'

  def self.cuis(branch_office, point_of_sale)
    company = branch_office.company
    client = SiatClient.client('siat_codes_invoices_wsdl', company)
    body = {
      SolicitudCuis: {
        codigoAmbiente: company.environment_type_id,
        codigoPuntoVenta: point_of_sale,
        codigoSistema: company.company_setting.system_code,
        nit: company.nit.to_i,
        codigoModalidad: company.modality_id,
        codigoSucursal: branch_office.number
      }
    }
    response = client.call(:cuis, message: body)

    response.to_array(:cuis_response, :respuesta_cuis).first
  end

  def self.cufd(branch_office, point_of_sale, cuis_code)
    company = branch_office.company
    client = SiatClient.client('siat_codes_invoices_wsdl', company)
    body = {
      SolicitudCufd: {
        codigoAmbiente: company.environment_type_id,
        codigoPuntoVenta: point_of_sale,
        codigoSistema: company.company_setting.system_code,
        nit: company.nit.to_i,
        codigoModalidad: company.modality_id,
        cuis: cuis_code.code,
        codigoSucursal: branch_office.number
      }
    }
    response = client.call(:cufd, message: body)
    response.to_array(:cufd_response, :respuesta_cufd).first
  end

  def self.economic_activities(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_actividades, message: body)

    response_transaction = response.to_array(:sincronizar_actividades_response, :respuesta_lista_actividades).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_actividades_response, :respuesta_lista_actividades, :lista_actividades)
  end

  def self.product_codes(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_lista_productos_servicios, message: body)
    response_transaction = response.to_array(:sincronizar_lista_productos_servicios_response, :respuesta_lista_productos).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_lista_productos_servicios_response, :respuesta_lista_productos, :lista_codigos)
  end

  def self.document_types(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_parametrica_tipo_documento_identidad, message: body)

    response_transaction = response.to_array(:sincronizar_parametrica_tipo_documento_identidad_response,
                                             :respuesta_lista_parametricas).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_parametrica_tipo_documento_identidad_response, :respuesta_lista_parametricas,
                      :lista_codigos)
  end

  def self.payment_methods(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_parametrica_tipo_metodo_pago, message: body)

    response_transaction = response.to_array(:sincronizar_parametrica_tipo_metodo_pago_response,
                                             :respuesta_lista_parametricas).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_parametrica_tipo_metodo_pago_response, :respuesta_lista_parametricas,
                      :lista_codigos)
  end

  def self.legends(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_lista_leyendas_factura, message: body)
    response_transaction = response.to_array(:sincronizar_lista_leyendas_factura_response,
                                             :respuesta_lista_parametricas_leyendas).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_lista_leyendas_factura_response, :respuesta_lista_parametricas_leyendas,
                      :lista_leyendas)
  end

  def self.measurements(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_parametrica_unidad_medida, message: body)

    response_transaction = response.to_array(:sincronizar_parametrica_unidad_medida_response,
                                             :respuesta_lista_parametricas).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_parametrica_unidad_medida_response, :respuesta_lista_parametricas,
                      :lista_codigos)
  end

  def self.significative_events(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_parametrica_eventos_significativos, message: body)

    response_transaction = response.to_array(:sincronizar_parametrica_eventos_significativos_response,
                                             :respuesta_lista_parametricas).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_parametrica_eventos_significativos_response, :respuesta_lista_parametricas,
                      :lista_codigos)
  end

  def self.pos_types(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_parametrica_tipo_punto_venta, message: body)

    response_transaction = response.to_array(:sincronizar_parametrica_tipo_punto_venta_response,
                                             :respuesta_lista_parametricas).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_parametrica_tipo_punto_venta_response, :respuesta_lista_parametricas,
                      :lista_codigos)
  end

  def self.cancellation_reasons(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_parametrica_motivo_anulacion, message: body)

    response_transaction = response.to_array(:sincronizar_parametrica_motivo_anulacion_response,
                                             :respuesta_lista_parametricas).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_parametrica_motivo_anulacion_response, :respuesta_lista_parametricas,
                      :lista_codigos)
  end

  def self.document_sectors(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_lista_actividades_documento_sector, message: body)

    response_transaction = response.to_array(:sincronizar_lista_actividades_documento_sector_response,
                                             :respuesta_lista_actividades_documento_sector).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_lista_actividades_documento_sector_response,
                      :respuesta_lista_actividades_documento_sector,
                      :lista_actividades_documento_sector)
  end

  def self.countries(branch_office, body)
    company = branch_office.company

    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_parametrica_pais_origen, message: body)

    response_transaction = response.to_array(:sincronizar_parametrica_pais_origen_response, :respuesta_lista_parametricas).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_parametrica_pais_origen_response, :respuesta_lista_parametricas,
                      :lista_codigos)
  end

  def self.issuance_types(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_parametrica_tipo_emision, message: body)

    response_transaction = response.to_array(:sincronizar_parametrica_tipo_emision_response,
                                             :respuesta_lista_parametricas).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_parametrica_tipo_emision_response, :respuesta_lista_parametricas,
                      :lista_codigos)
  end

  def self.room_types(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_parametrica_tipo_habitacion, message: body)

    response_transaction = response.to_array(:sincronizar_parametrica_tipo_habitacion_response,
                                             :respuesta_lista_parametricas).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_parametrica_tipo_habitacion_response, :respuesta_lista_parametricas,
                      :lista_codigos)
  end

  def self.currency_types(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_parametrica_tipo_moneda, message: body)

    response_transaction = response.to_array(:sincronizar_parametrica_tipo_moneda_response, :respuesta_lista_parametricas).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_parametrica_tipo_moneda_response, :respuesta_lista_parametricas,
                      :lista_codigos)
  end

  def self.invoice_types(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_parametrica_tipos_factura, message: body)

    response_transaction = response.to_array(:sincronizar_parametrica_tipos_factura_response,
                                             :respuesta_lista_parametricas).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_parametrica_tipos_factura_response, :respuesta_lista_parametricas,
                      :lista_codigos)
  end

  def self.service_messages(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_lista_mensajes_servicios, message: body)

    response_transaction = response.to_array(:sincronizar_lista_mensajes_servicios_response,
                                             :respuesta_lista_parametricas).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_lista_mensajes_servicios_response, :respuesta_lista_parametricas,
                      :lista_codigos)
  end

  def self.document_sector_types(branch_office, body)
    company = branch_office.company
    client = SiatClient.client('siat_sync_invoice_wsdl', company)

    response = client.call(:sincronizar_parametrica_tipo_documento_sector, message: body)

    response_transaction = response.to_array(:sincronizar_parametrica_tipo_documento_sector_response,
                                             :respuesta_lista_parametricas).first

    unless response_transaction[:transaccion]
      return "La solicitud a SIAT obtuvo el siguiente error: #{response_transaction[:mensajes_list][:descripcion]}"
    end

    response.to_array(:sincronizar_parametrica_tipo_documento_sector_response, :respuesta_lista_parametricas,
                      :lista_codigos)
  end
end
