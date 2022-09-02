class InvoiceXml
  def self.generate(invoice)
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
end