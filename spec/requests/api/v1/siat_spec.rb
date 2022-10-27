# frozen_string_literal: true

require 'rails_helper'
require 'savon/mock/spec_helper'

RSpec.describe 'Api::V1::Siat', type: :request do
  include Savon::SpecHelper
  require 'siat_available'
  require 'client_call'

  describe 'POST /generate_cuis' do
    context 'with valid response of siat' do
      let(:branch_office) { create(:branch_office) }

      response = { codigo: '6996E20D', fecha_vigencia: DateTime.now + 1.year,
                   mensajes_list: { codigo: '980', descripcion: 'EXISTE UN CUIS VIGENTE PARA LA SUCURSAL O PUNTO DE VENTA' },
                   transaccion: false }

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:cuis).and_return(response)
      end

      it 'returns http success' do
        expect do
          post api_v1_branch_office_siat_generate_cuis_url(branch_office), params: { point_of_sale: 0 }, as: :json
        end.to change(branch_office.cuis_codes, :count).by(1)
      end
    end

    context 'with valid response of siat' do
      let(:branch_office) { create(:branch_office) }

      response = { codigo: '6996E20D', fecha_vigencia: DateTime.now + 1.year,
                   mensajes_list: { codigo: '900', descripcion: 'EXISTE UN CUIS VIGENTE PARA LA SUCURSAL O PUNTO DE VENTA' },
                   transaccion: false }

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:cuis).and_return(response)
      end

      it 'returns http success' do
        expect do
          post api_v1_branch_office_siat_generate_cuis_url(branch_office), params: { point_of_sale: 0 }, as: :json
        end.to change(branch_office.cuis_codes, :count).by(0)
      end
    end
  end

  describe 'GET /show_cuis' do
    let(:branch_office) { create(:branch_office) }
    before { create(:cuis_code, branch_office: branch_office) }

    it 'returns http success' do
      get api_v1_branch_office_siat_show_cuis_url(branch_office_id: branch_office.id, point_of_sale: 0)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /generate_cufd' do
    context 'with valid response of siat' do
      let(:branch_office) { create(:branch_office) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = { codigo: 'ABC', codigo_control: '68525B7E4AE6D74',
                   direccion: 'AVENIDA 26 DE FEBRERO NRO.519 ZONA FE Y ALEGRIA UV:0011 MZA:0006',
                   fecha_vigencia: DateTime.now + 1.day, transaccion: true }

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:cufd).and_return(response)
      end

      it 'returns http success' do
        expect do
          post api_v1_branch_office_siat_generate_cufd_url(branch_office), params: { point_of_sale: 0 }, as: :json
        end.to change(branch_office.daily_codes, :count).by(1)
      end
    end

    context 'with invalid response of siat' do
      let(:branch_office) { create(:branch_office) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = { codigo: 'ABC', codigo_control: '68525B7E4AE6D74',
                   direccion: 'AVENIDA 26 DE FEBRERO NRO.519 ZONA FE Y ALEGRIA UV:0011 MZA:0006',
                   fecha_vigencia: DateTime.now + 1.day, transaccion: false }

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:cufd).and_return(response)
      end

      it 'returns http success' do
        expect do
          post api_v1_branch_office_siat_generate_cufd_url(branch_office), params: { point_of_sale: 0 }, as: :json
        end.to change(branch_office.daily_codes, :count).by(0)
      end
    end
  end

  describe 'GET /show_cufd' do
    let(:branch_office) { create(:branch_office) }
    before { create(:daily_code, branch_office: branch_office) }

    it 'returns http success' do
      get api_v1_branch_office_siat_show_cufd_url(branch_office_id: branch_office.id, point_of_sale: 0)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /economic_activities' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_caeb: '464300', descripcion: 'VENTA AL POR MAYOR DE OTROS PRODUCTOS', tipo_actividad: 'P' },
        { codigo_caeb: '001220', descripcion: 'ACTIVIDADES SOLO DE IMPORTACIÓN', tipo_actividad: 'S' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:economic_activities).and_return(response)
      end

      it 'returns http success' do
        expect do
          post api_v1_branch_office_siat_economic_activities_url(branch_office), as: :json
        end.to change(company.economic_activities, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:economic_activities).and_return(response)
      end

      it 'returns http success' do
        expect do
          post api_v1_branch_office_siat_economic_activities_url(branch_office), as: :json
        end.to change(company.economic_activities, :count).by(0)
      end
    end
  end

  describe 'POST /product_codes' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      before { create(:economic_activity, company: company) }
      before { create(:economic_activity, code: '67890', company: company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_actividad: '12345', codigo_producto: '61291', descripcion_producto: 'ABC' },
        { codigo_actividad: '67890', codigo_producto: '61292', descripcion_producto: 'DEF' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:product_codes).and_return(response)
      end

      it 'returns http success' do
        expect do
          post api_v1_branch_office_siat_product_codes_url(branch_office), params: { point_of_sale: 0 }, as: :json
        end.to change(ProductCode, :count).by(2)
      end
    end

    context 'with valid response of siat' do
      let(:company) { create(:company) }
      before { create(:economic_activity, company: company) }
      before { create(:economic_activity, code: '67890', company: company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:product_codes).and_return(response)
      end

      it 'returns http success' do
        expect do
          post api_v1_branch_office_siat_product_codes_url(branch_office), params: { point_of_sale: 0 }, as: :json
        end.to change(ProductCode, :count).by(0)
      end
    end
  end

  describe 'POST /document_types' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_clasificador: '1', descripcion: 'CI - CEDULA DE IDENTIDAD' },
        { codigo_clasificador: '2', descripcion: 'CEX - CEDULA DE IDENTIDAD DE EXTRANJERO' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:document_types).and_return(response)
      end

      it 'insert to table' do
        expect do
          post api_v1_branch_office_siat_document_types_url(branch_office), as: :json
        end.to change(DocumentType, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:document_types).and_return(response)
      end
      it 'not insert to table' do
        expect do
          post api_v1_branch_office_siat_document_types_url(branch_office), as: :json
        end.to change(DocumentType, :count).by(0)
      end
    end
  end

  describe 'POST /payment_methods' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_clasificador: '1', descripcion: 'EFECTIVO' },
        { codigo_clasificador: '2', descripcion: 'TARJETA' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:payment_methods).and_return(response)
      end

      it 'insert to table' do
        expect do
          post api_v1_branch_office_siat_payment_methods_url(branch_office), as: :json
        end.to change(PaymentMethod, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:payment_methods).and_return(response)
      end
      it 'not insert to table' do
        expect do
          post api_v1_branch_office_siat_payment_methods_url(branch_office), as: :json
        end.to change(PaymentMethod, :count).by(0)
      end
    end
  end

  describe 'POST /legends' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      before { create(:economic_activity, company: company) }
      before { create(:economic_activity, code: '67890', company: company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_actividad: '12345', descripcion_leyenda: 'Ley N° 453: Está' },
        { codigo_actividad: '67890', descripcion_leyenda: 'Ley N° 453: Los' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:legends).and_return(response)
      end

      it 'insert to table' do
        expect do
          post api_v1_branch_office_siat_legends_url(branch_office), as: :json
        end.to change(Legend, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      before { create(:economic_activity, company: company) }
      before { create(:economic_activity, code: '67890', company: company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:legends).and_return(response)
      end
      it 'not insert to table' do
        expect do
          post api_v1_branch_office_siat_legends_url(branch_office), as: :json
        end.to change(Legend, :count).by(0)
      end
    end
  end

  describe 'POST /measurements' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_clasificador: '1', descripcion: 'BOBINAS' },
        { codigo_clasificador: '2', descripcion: 'BALDE' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:measurements).and_return(response)
      end

      it 'insert to table' do
        expect do
          post api_v1_branch_office_siat_measurements_url(branch_office), as: :json
        end.to change(Measurement, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:measurements).and_return(response)
      end
      it 'not insert to table' do
        expect do
          post api_v1_branch_office_siat_measurements_url(branch_office), as: :json
        end.to change(Measurement, :count).by(0)
      end
    end
  end

  describe 'POST /significative_events' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_clasificador: '1', descripcion: 'CORTE DEL SERVICIO DE INTERNET' },
        { codigo_clasificador: '2', descripcion: 'INACCESIBILIDAD AL SERVICIO' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:significative_events).and_return(response)
      end

      it 'insert to table' do
        expect do
          post api_v1_branch_office_siat_significative_events_url(branch_office), as: :json
        end.to change(SignificativeEvent, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:significative_events).and_return(response)
      end
      it 'not insert to table' do
        expect do
          post api_v1_branch_office_siat_significative_events_url(branch_office), as: :json
        end.to change(SignificativeEvent, :count).by(0)
      end
    end
  end

  describe 'POST /pos_types' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_clasificador: '1', descripcion: 'PUNTO VENTA COMISIONISTA' },
        { codigo_clasificador: '2', descripcion: 'PUNTO VENTA VENTANILLA DE COBRANZA' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:pos_types).and_return(response)
      end

      it 'insert to table' do
        expect do
          post api_v1_branch_office_siat_pos_types_url(branch_office), as: :json
        end.to change(PosType, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:pos_types).and_return(response)
      end
      it 'not insert to table' do
        expect do
          post api_v1_branch_office_siat_pos_types_url(branch_office), as: :json
        end.to change(PosType, :count).by(0)
      end
    end
  end

  describe 'POST /cancellation_reasons' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_clasificador: '1', descripcion: 'FACTURA MAL EMITIDA' },
        { codigo_clasificador: '2', descripcion: 'NOTA DE CREDITO-DEBITO MAL EMITIDA' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:cancellation_reasons).and_return(response)
      end

      it 'insert to table' do
        expect do
          post api_v1_branch_office_siat_cancellation_reasons_url(branch_office), as: :json
        end.to change(CancellationReason, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:cancellation_reasons).and_return(response)
      end
      it 'not insert to table' do
        expect do
          post api_v1_branch_office_siat_cancellation_reasons_url(branch_office), as: :json
        end.to change(CancellationReason, :count).by(0)
      end
    end
  end

  describe 'POST /document_sectors' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      before { create(:economic_activity, company: company) }
      before { create(:economic_activity, code: '67890', company: company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_actividad: '12345', codigo_documento_sector: '35', tipo_documento_sector: 'FAC_CVB' },
        { codigo_actividad: '67890', codigo_documento_sector: '34', tipo_documento_sector: 'FAC_SEG' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:document_sectors).and_return(response)
      end

      it 'insert to table' do
        expect do
          post api_v1_branch_office_siat_document_sectors_url(branch_office), as: :json
        end.to change(DocumentSector, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      before { create(:economic_activity, company: company) }
      before { create(:economic_activity, code: '67890', company: company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:document_sectors).and_return(response)
      end
      it 'not insert to table' do
        expect do
          post api_v1_branch_office_siat_document_sectors_url(branch_office), as: :json
        end.to change(DocumentSector, :count).by(0)
      end
    end
  end

  describe 'POST /countries' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_clasificador: '1', descripcion: 'AFGANISTÁN' },
        { codigo_clasificador: '2', descripcion: 'ALBANIA' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:countries).and_return(response)
      end

      it 'insert to table' do
        expect do
          post api_v1_branch_office_siat_countries_url(branch_office), as: :json
        end.to change(Country, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:countries).and_return(response)
      end
      it 'not insert to table' do
        expect do
          post api_v1_branch_office_siat_countries_url(branch_office), as: :json
        end.to change(Country, :count).by(0)
      end
    end
  end

  describe 'POST /issuance_types' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_clasificador: '1', descripcion: 'EN LINEA' },
        { codigo_clasificador: '2', descripcion: 'FUERA DE LINEA' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:issuance_types).and_return(response)
      end

      it 'insert to table' do
        expect do
          post api_v1_branch_office_siat_issuance_types_url(branch_office), as: :json
        end.to change(IssuanceType, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:issuance_types).and_return(response)
      end
      it 'not insert to table' do
        expect do
          post api_v1_branch_office_siat_issuance_types_url(branch_office), as: :json
        end.to change(IssuanceType, :count).by(0)
      end
    end
  end

  describe 'POST /room_types' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_clasificador: '1', descripcion: 'HABITACIÓN SENCILLA' },
        { codigo_clasificador: '2', descripcion: 'HABITACIÓN DOBLE' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:room_types).and_return(response)
      end

      it 'insert to table' do
        expect do
          post api_v1_branch_office_siat_room_types_url(branch_office), as: :json
        end.to change(RoomType, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:room_types).and_return(response)
      end
      it 'not insert to table' do
        expect do
          post api_v1_branch_office_siat_room_types_url(branch_office), as: :json
        end.to change(RoomType, :count).by(0)
      end
    end
  end

  describe 'POST /currency_types' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_clasificador: '1', descripcion: 'BOLIVIANO' },
        { codigo_clasificador: '2', descripcion: 'DOLAR' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:currency_types).and_return(response)
      end

      it 'insert to table' do
        expect do
          post api_v1_branch_office_siat_currency_types_url(branch_office), as: :json
        end.to change(CurrencyType, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:currency_types).and_return(response)
      end
      it 'not insert to table' do
        expect do
          post api_v1_branch_office_siat_currency_types_url(branch_office), as: :json
        end.to change(CurrencyType, :count).by(0)
      end
    end
  end

  describe 'POST /invoice_types' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_clasificador: '1', descripcion: 'FACTURA CON DERECHO A CREDITO FISCAL' },
        { codigo_clasificador: '2', descripcion: 'FACTURA SIN DERECHO A CREDITO FISCAL' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:invoice_types).and_return(response)
      end

      it 'insert to table' do
        expect do
          post api_v1_branch_office_siat_invoice_types_url(branch_office), as: :json
        end.to change(InvoiceType, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:invoice_types).and_return(response)
      end
      it 'not insert to table' do
        expect do
          post api_v1_branch_office_siat_invoice_types_url(branch_office), as: :json
        end.to change(InvoiceType, :count).by(0)
      end
    end
  end

  describe 'POST /service_messages' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_clasificador: '903', descripcion: 'RECEPCION PROCESADA' },
        { codigo_clasificador: '904', descripcion: 'RECEPCION OBSERVADA' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:service_messages).and_return(response)
      end

      it 'insert to table' do
        expect do
          post api_v1_branch_office_siat_service_messages_url(branch_office), as: :json
        end.to change(ServiceMessage, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:service_messages).and_return(response)
      end
      it 'not insert to table' do
        expect do
          post api_v1_branch_office_siat_service_messages_url(branch_office), as: :json
        end.to change(ServiceMessage, :count).by(0)
      end
    end
  end

  describe 'POST /document_sector_types' do
    context 'with valid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = [
        { codigo_clasificador: '1', descripcion: 'FACTURA COMPRA-VENTA' },
        { codigo_clasificador: '2', descripcion: 'FACTURA DE ALQUILER DE BIENES INMUEBLES' }
      ]

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:document_sector_types).and_return(response)
      end

      it 'insert to table' do
        expect do
          post api_v1_branch_office_siat_document_sector_types_url(branch_office), as: :json
        end.to change(DocumentSectorType, :count).by(2)
      end
    end

    context 'with invalid response of siat' do
      let(:company) { create(:company) }
      let(:branch_office) { create(:branch_office, company: company) }
      before { create(:cuis_code, default_values: true, branch_office: branch_office) }

      response = 'Error'

      before(:each) do
        allow(SiatAvailable).to receive(:available).and_return(true)
        allow(ClientCall).to receive(:document_sector_types).and_return(response)
      end
      it 'not insert to table' do
        expect do
          post api_v1_branch_office_siat_document_sector_types_url(branch_office), as: :json
        end.to change(DocumentSectorType, :count).by(0)
      end
    end
  end
end
