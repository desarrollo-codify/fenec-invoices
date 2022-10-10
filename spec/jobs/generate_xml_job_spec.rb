# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateXmlJob, type: :job do
  let(:branch_office) do
    BranchOffice.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id)
  end
  let(:invoice_status) { InvoiceStatus.create!(description: 'Good') }
  let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }

  let(:invoice) { create(:invoice, branch_office: branch_office, invoice_status: invoice_status) }

  describe '#perform_later' do
    it 'generate xml an invoice' do
      ActiveJob::Base.queue_adapter = :test
      expect do
        GenerateXmlJob.perform_later(invoice)
      end.to have_enqueued_job
    end
  end
end
