# frozen_string_literal: true

class CloseContingencyJob < ApplicationJob
  queue_as :default
  require 'rubygems/package'

  def perform(contingency)
    contingency.close!
    invoices = find_invoices(contingency)

    @pending_invoices = invoices.by_cufd(contingency.cufd_code)
    current_cuis = contingency.point_of_sale.branch_office.cuis_codes
                              .by_pos(@pending_invoices.last.point_of_sale).current.code
    current_cufd = contingency.point_of_sale.branch_office.daily_codes
                              .by_pos(@pending_invoices.last.point_of_sale).current.code

    return if @pending_invoices.empty?

    @pending_invoices.update_all(contingency_id: contingency.id)
    event_cufd = @pending_invoices.first.cufd_code
    send_contingency(contingency, event_cufd, current_cuis, current_cufd) unless contingency.event_reception_code.present?
    send_package(@pending_invoices, contingency, current_cuis, current_cufd) unless contingency.reception_code.present?
    delete_files(@pending_invoices)
    reception_validation(@pending_invoices, contingency, current_cuis, current_cufd)

    SendCancelInvoicesJob.perform_later(contingency)
  end

  def send_contingency(contingency, contingency_cufd, current_cuis, current_cufd)
    branch_office = contingency.point_of_sale.branch_office

    client = Savon.client(
      wsdl: ENV.fetch('siat_operations'.to_s, nil),
      headers: {
        'apikey' => branch_office.company.company_setting.api_key,
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )
    body = {
      SolicitudEventoSignificativo: {
        codigoAmbiente: branch_office.company.environment_type_id,
        codigoPuntoVenta: contingency.point_of_sale.code,
        codigoSistema: branch_office.company.company_setting.system_code,
        nit: branch_office.company.nit.to_i,
        cuis: current_cuis,
        cufd: current_cufd,
        codigoSucursal: branch_office.number,
        codigoMotivoEvento: contingency.significative_event_id,
        descripcion: contingency.significative_event.description,
        fechaHoraInicioEvento: contingency.start_date.strftime('%Y-%m-%dT%H:%M:%S.%L'),
        fechaHoraFinEvento: contingency.end_date.strftime('%Y-%m-%dT%H:%M:%S.%L'),
        cufdEvento: contingency_cufd
      }
    }
    begin
      response = client.call(:registro_evento_significativo, message: body)

      data = response.to_array(:registro_evento_significativo_response, :respuesta_lista_eventos).first

      code = data[:codigo_recepcion_evento_significativo]
      contingency.update(event_reception_code: code)
    rescue StandardError => e
      contingency.contingency_logs.create(code: 1000,
                                          description: "No se pudo registrar la contigencia en el SIAT por
                                                        el siguiente mensaje de error: #{e}")
    end
  end

  def send_package(invoices, contingency, current_cuis, current_cufd)
    invoices.each do |invoice|
      GenerateXmlJob.perform_now(invoice, true)
    end

    filename = "#{Rails.root}/tmp/invoices/"
    tar = create_tar(filename)
    zipped_filename = "#{tar}.gz"

    Zlib::GzipWriter.open(zipped_filename) do |gz|
      gz.write File.binread(tar)
    end

    base64_file = Base64.strict_encode64(File.binread(zipped_filename))
    hash = Digest::SHA2.hexdigest(base64_file)

    branch_office = contingency.point_of_sale.branch_office
    company = branch_office.company
    economic_activities = company.economic_activities

    client = Savon.client(
      wsdl: ENV.fetch('siat_pilot_invoices'.to_s, nil),
      headers: {
        'apikey' => company.company_setting.api_key,
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )

    cafc = contingency.manual_type? ? economic_activities.first.contingency_codes.available.last.code : nil

    body = {
      SolicitudServicioRecepcionPaquete: {
        codigoAmbiente: branch_office.company.environment_type_id,
        codigoPuntoVenta: contingency.point_of_sale.code,
        codigoSistema: company.company_setting.system_code,
        codigoSucursal: branch_office.number,
        nit: branch_office.company.nit.to_i,
        codigoDocumentoSector: branch_office.company.document_types.first.code,
        codigoEmision: 2, # TODO: Refactor
        codigoModalidad: branch_office.company.modality_id,
        cufd: current_cufd,
        cuis: current_cuis,
        cafc: cafc,
        tipoFacturaDocumento: branch_office.company.invoice_types.first.code,
        archivo: base64_file,
        fechaEnvio: DateTime.now.strftime('%Y-%m-%dT%H:%M:%S.%L'),
        hashArchivo: hash,
        cantidadFacturas: invoices.count,
        codigoEvento: contingency.event_reception_code
      }
    }
    begin
      response = client.call(:recepcion_paquete_factura, message: body)

      data = response.to_array(:recepcion_paquete_factura_response, :respuesta_servicio_facturacion).first
      code = data[:codigo_recepcion]
      contingency.update(reception_code: code)
    rescue StandardError => e
      contingency.contingency_logs.create(code: 1000,
                                          description: "No se pudo enviar el paquete de facturas al SIAT
                                                        por el siguiente mensaje de error: #{e}")
    end
  end

  def reception_validation(_invoices, contingency, current_cuis, current_cufd)
    branch_office = contingency.point_of_sale.branch_office

    client = Savon.client(
      wsdl: ENV.fetch('siat_pilot_invoices'.to_s, nil),
      headers: {
        'apikey' => branch_office.company.company_setting.api_key,
        'SOAPAction' => ''
      },
      namespace: ENV.fetch('siat_namespace', nil),
      convert_request_keys_to: :none
    )

    body = {
      SolicitudServicioValidacionRecepcionPaquete: {
        codigoAmbiente: branch_office.company.environment_type_id,
        codigoPuntoVenta: contingency.point_of_sale.code,
        codigoSistema: branch_office.company.company_setting.system_code,
        codigoSucursal: branch_office.number,
        nit: branch_office.company.nit.to_i,
        codigoDocumentoSector: branch_office.company.document_types.first.code,
        codigoEmision: 2,
        codigoModalidad: branch_office.company.modality_id,
        cufd: current_cufd,
        cuis: current_cuis,
        tipoFacturaDocumento: branch_office.company.invoice_types.first.code,
        codigoRecepcion: contingency.reception_code
      }
    }
    sleep 10

    begin
      response = client.call(:validacion_recepcion_paquete_factura, message: body)

      data = response.to_array(:validacion_recepcion_paquete_factura_response, :respuesta_servicio_facturacion).first
      status_code = data[:codigo_estado]
      description = data[:codigo_descripcion]
      contingency.update(status: description)
      # 901 Pendiente, 902 Rechazada, 904 Observada, 908 Validado
      if status_code == '904'
        errors_list = data[:mensajes_list]
        errors_list.each do |error|
          code = error[:codigo]
          description = error[:descripcion]
          contingency.contingency_logs.create(code: code, description: description)
        end
      end
      InvoiceStatusJob.perform_now(@pending_invoices)
    rescue StandardError => e
      contingency.contingency_logs.create(code: 1000,
                                          description: "No se pudo verficar la recepción del paquete facturas
                                                        enviado al SIAT por el siguiente mensaje de error: #{e}")
    end
  end

  private

  def delete_files(invoices)
    invoices.each do |invoice|
      filename = "#{Rails.root}/tmp/invoices/#{invoice.cuf}.xml"
      FileUtils.rm_f(filename)
    end
  end

  def find_invoices(contingency)
    invoices = contingency.invoices
    return invoices if invoices.present?

    point_of_sale = contingency.point_of_sale.code
    if contingency.manual_type?
      contingency.point_of_sale.branch_office.invoices.by_point_of_sale(point_of_sale).where(is_manual: true)
    else
      contingency.point_of_sale.branch_office.invoices.by_point_of_sale(point_of_sale).where(is_manual: false)
    end
  end

  BLOCKSIZE_TO_READ = 1024 * 1000

  def create_tar(path)
    tar_filename = "#{Pathname.new(path).realpath.to_path}.tar"

    File.open(tar_filename, 'wb') do |tarfile|
      Gem::Package::TarWriter.new(tarfile) do |tar|
        Dir[File.join(path, '*')].each do |file|
          mode = File.stat(file).mode
          relative_file = file.sub(%r{^#{Regexp.escape(path)}/?}, '')

          if File.directory?(file)
            tar.mkdir(relative_file, mode)
          else

            tar.add_file(relative_file, mode) do |tf|
              File.open(file, 'rb') do |f|
                while buffer = f.read(BLOCKSIZE_TO_READ)
                  tf.write buffer
                end
              end
            end

          end
        end
      end
    end
    tar_filename
  end
end
