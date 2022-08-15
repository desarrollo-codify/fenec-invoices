# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/branch_offices', type: :request do
  let(:invalid_attributes) do
    {
      name: nil,
      number: 'A',
      address: nil
    }
  end

  let(:valid_headers) do
    {}
  end

  describe 'GET /show' do
    let(:branch_office) { create(:branch_office) }

    it 'renders a successful response' do
      get api_v1_branch_office_url(branch_office), as: :json
      expect(response).to be_successful
    end
  end

  describe 'PUT /update' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: 'new name' } }
      let(:branch_office) { create(:branch_office) }

      it 'updates the requested branch_office' do
        put api_v1_branch_office_url(branch_office),
              params: { branch_office: new_attributes }, headers: valid_headers, as: :json
        branch_office.reload
        expect(branch_office.name).to eq('new name')
      end

      it 'renders a JSON response with the branch_office' do
        put api_v1_branch_office_url(branch_office),
              params: { branch_office: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      let(:branch_office) { create(:branch_office) }

      it 'renders a JSON response with errors for the branch_office' do
        patch api_v1_branch_office_url(branch_office),
              params: { branch_office: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested branch_office' do
      branch_office = create(:branch_office)
      expect do
        delete api_v1_branch_office_url(branch_office), headers: valid_headers, as: :json
      end.to change(BranchOffice, :count).by(-1)
    end
  end
end
