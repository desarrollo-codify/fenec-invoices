# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceStatusJob, type: :job do
  let(:branch_office) do
    BranchOffice.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id)
  end
  let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }

  let(:contingency) { create(:contingency, point_of_sale: branch_office.point_of_sales.first) }

  describe '#perform_later' do
    it 'generate xml an invoice' do
      ActiveJob::Base.queue_adapter = :test
      expect do
        InvoiceStatusJob.perform_later(contingency)
      end.to have_enqueued_job
    end
  end
end
