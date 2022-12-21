# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CancelInvoiceJob, type: :job do
  let(:branch_office) do
    BranchOffice.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id)
  end
  let(:invoice_status) { InvoiceStatus.create!(description: 'Good') }
  let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }

  let(:invoice) { build(:invoice, branch_office: branch_office, invoice_status: invoice_status) }

  describe '#perform_later' do
    before { create(:payment_method) }

    before(:each) do
      invoice.payments.build(mount: 1, payment_method_id: 1)
      invoice.save
    end

    it 'cancels an invoice' do
      ActiveJob::Base.queue_adapter = :test
      expect do
        CancelInvoiceJob.perform_later(invoice, 2)
      end.to have_enqueued_job
    end
  end
end
