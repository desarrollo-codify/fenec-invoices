# frozen_string_literal: true

class ApplicationController < ActionController::API
  
  def generate_xml(invoice)
    header = Nokogiri::XML('<?xml version = "1.0" encoding = "UTF-8" standalone ="yes"?>')
    builder = Nokogiri::XML::Builder.with(header) do |xml|
      xml.facturaComputarizadaCompraVenta('xsi:noNamespaceSchemaLocation' => '/compraVenta/facturaComputarizadaCompraVenta.xsd',
                                          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance') do
        xml.cabecera do
          xml.nitEmisor invoice.company_nit
          xml.razonSocialEmisor invoice.company_name
          xml.municipio invoice.municipality
          xml.telefono invoice.phone
          xml.numeroFactura invoice.number
          xml.cuf invoice.cuf
          xml.cufd invoice.cufd_code
          xml.codigoSucursal invoice.branch_office_number
          xml.direccion invoice.address

          # point of sale
          xml.codigoPuntoVenta('xsi:nil' => true) unless invoice.point_of_sale
          xml.codigoPuntoVenta invoice.point_of_sale if invoice.point_of_sale

          xml.fechaEmision invoice.date.strftime('%FT%T.%L') # format: "2022-08-21T19:26:40.905"
          xml.nombreRazonSocial invoice.business_name
          xml.codigoTipoDocumentoIdentidad invoice.document_type
          xml.numeroDocumento invoice.business_nit
          
          # complement
          xml.complemento('xsi:nil' => true) unless invoice.complement
          xml.complemento invoice.complement if invoice.complement

          xml.codigoCliente invoice.client_code
          xml.codigoMetodoPago invoice.payment_method

          # card number
          xml.numeroTarjeta('xsi:nil' => true) unless invoice.card_number
          xml.numeroTarjeta @invoice.card_number if invoice.card_number

          xml.montoTotal invoice.total
          xml.montoTotalSujetoIva invoice.total # TODO: check for not IVA
          xml.codigoMoneda invoice.currency_code
          xml.tipoCambio invoice.exchange_rate
          xml.montoTotalMoneda invoice.currency_total
          xml.montoGiftCard invoice.gift_card_total
          xml.descuentoAdicional invoice.discount

          # exception code
          xml.codigoExcepcion('xsi:nil' => true) unless invoice.exception_code
          xml.codigoExcepcion invoice.exception_code if invoice.exception_code

          # cafc
          xml.cafc('xsi:nil' => true) unless invoice.cafc
          xml.cafc @invoice.cafc if invoice.cafc

          xml.leyenda invoice.legend
          xml.usuario invoice.user

          # document sector
          xml.codigoDocumentoSector('xsi:nil' => true) unless invoice.document_sector_code
          xml.codigoDocumentoSector invoice.document_sector_code if invoice.document_sector_code
        end
        invoice.invoice_details.each do |detail|
          xml.detalle do
            xml.actividadEconomica detail.economic_activity_code # invoice.invoice_details.activity_type
            xml.codigoProductoSin detail.sin_code
            xml.codigoProducto detail.product_code
            xml.descripcion detail.description
            xml.cantidad detail.quantity
            xml.unidadMedida detail.measurement_id
            xml.precioUnitario detail.unit_price
            xml.montoDescuento detail.discount
            xml.subTotal detail.subtotal

            # card number
            xml.numeroSerie('xsi:nil' => true) unless detail.serial_number
            xml.numeroSerie detail.serial_number if detail.serial_number

            # imei number
            xml.numeroImei('xsi:nil' => true) unless detail.imei_code
            xml.numeroImei detail.imei_code if detail.imei_code
          end
        end
      end
    end

    builder.to_xml
  end

  def siat_available
    client =Savon.client(
              wsdl: ENV.fetch('siat_invoices'.to_s, nil),
              headers: {
                'apikey' => ENV.fetch('api_key', nil),
                'SOAPAction' => ''
              },
              namespace: ENV.fetch('siat_namespace', nil),
              convert_request_keys_to: :none
            )

    response = client.call(:verificar_comunicacion)
    if response.success?
      data = response.to_array(:verificar_comunicacion_response).first
      data = data[:return]
    else
      data = {return: 'communication error'}
    end
    data == '926'
  end

  def ContingencyRecord(branch_office, invoice)
    cuis_code = branch_office.cuis_codes.last
    cufd_code = branch_office.daily_codes.last
    contingency = branch_office.contingencies.last
    client =Savon.client(
      wsdl: ENV.fetch('siat_operations'.to_s, nil),
      headers: {
        'apikey' => ENV.fetch('api_key', nil),
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )

    body = {
      SolicitudEventoSignificativo: {
        codigoAmbiente: 2,
        codigoSistema: ENV.fetch('system_code', nil),
        nit: branch_office.company.nit.to_i,
        cuis: cuis_code.code,
        cufd: cufd_code.code,
        codigoSucursal: branch_office.number,
        codigoPuntoVenta: 0,
        codigoMotivoEvento: contingency.significative_event_id,
        descripcion: contingency.significative_event.description,
        fechaHoraInicioEvento: contingency.start_date,
        fechaHoraFinEvento: contingency.end_date,
        cufdEvento: invoice.cufd_code,
      }
    }
    response = client.call(:registro_evento_significativo, message: body)
    if response.success?
      data = response.to_array(:registro_evento_significativo_response, :respuesta_lista_eventos, :mensajes_list)
      data = data[:return]
    else
      data = {return: 'communication error'}
    end
    return data
  end

  def ReceptionValidation(branch_office)
    cuis_code = branch_office.cuis_codes.last
    cufd_code = branch_office.daily_codes.last
    contingency = branch_office.contingencies.last
    client =Savon.client(
      wsdl: ENV.fetch('siat_invoices'.to_s, nil),
      headers: {
        'apikey' => ENV.fetch('api_key', nil),
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )

    body = {
      SolicitudServicioValidacionRecepcionPaquete: {
        codigoAmbiente: 2,
        codigoSistema: ENV.fetch('system_code', nil),
        codigoSucursal: branch_office.number,
        nit: branch_office.company.nit.to_i,
        codigoDocumentoSector: 1
        codigoEmision: 2
        codigoModalidad: 2
        cufd: cufd_code.code,
        cuis: cuis_code.code,
        tipoFacturaDocumento: 1
        codigoRecepcion: 
      }
    }
    response = client.call(:validacion_recepcion_paquete_factura, message: body)
    if response.success?
      data = response.to_array(:validacion_recepcion_paquete_factura_response, :respuesta_servicio_facturacion , :mensajes_list)
      data = data[:return]
    else
      data = {return: 'communication error'}
    end
    return data
  end
end
