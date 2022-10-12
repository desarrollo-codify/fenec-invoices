# frozen_string_literal: true

require 'rails_helper'
require 'savon/mock/spec_helper'

RSpec.describe 'Api::V1::Siat', type: :request do
  include Savon::SpecHelper

  before(:all) { savon.mock!   }
  after(:all)  { savon.unmock! }
  # describe 'POST /generate_cuis' do
  #   let(:branch_office) { create(:branch_office) }

  #   it 'returns http success' do
  #     post api_v1_branch_office_siat_generate_cuis_url(branch_office_id: branch_office.id)
  #     expect(response).to have_http_status(:success)
  #   end

  #   context 'generate cuis' do
  #     it 'response of generate cuis' do
  #       fixture = true

  #       savon.expects(:generate_cuis).returns(fixture)

  #       service = SiatController.new
  #       response = service.generate_cuis

  #       expect(response).to be_successful
  #     end
  #   end
  # end

  describe 'GET /show_cuis' do
    let(:branch_office) { create(:branch_office) }
    before { create(:cuis_code, branch_office: branch_office) }

    it 'returns http success' do
      get api_v1_branch_office_siat_show_cuis_url(branch_office_id: branch_office.id, point_of_sale: 0)
      expect(response).to have_http_status(:success)
    end
  end

  # describe 'POST /generate_cufd' do
  #   let(:branch_office) { create(:branch_office) }

  #   it 'returns http success' do
  #     post api_v1_branch_office_siat_generate_cufd_url(branch_office_id: branch_office.id)
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  describe 'GET /show_cufd' do
    let(:branch_office) { create(:branch_office) }
    before { create(:daily_code, branch_office: branch_office) }

    it 'returns http success' do
      get api_v1_branch_office_siat_show_cufd_url(branch_office_id: branch_office.id, point_of_sale: 0)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /significative_events' do
    let(:branch_office) { create(:branch_office) }
    before { create(:cuis_code, branch_office: branch_office) }
    before { create(:company_setting, company: branch_office.company) }

    # it 'returns http success' do
    #   # TODO: Implement test of savon.
    #   # message = { SolicitudSincronizacion: { codigoAmbiente: 2, codigoSistema: '2', nit: 123, cuis: 'ABC', codigoSucursal: 1 } }
    #   # savon.expects(:sincronizar_parametrica_eventos_significativos).with(message: message).returns(['hola'])

    #   post api_v1_branch_office_siat_significative_events_url(branch_office_id: branch_office.id)
    #   expect(response).to have_http_status(:success)
    # end

    # it 'bulk insert records' do
    # end
  end
  # describe 'POST /siat_product_codes' do
  #   it 'returns http success' do
  #     get '/api/v1/siat/siat_codes'
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # describe 'GET /bulk_products_update' do
  #   it 'returns http success' do
  #     get '/api/v1/siat/bulk_products_update'
  #     expect(response).to have_http_status(:success)
  #   end
  # end
end
