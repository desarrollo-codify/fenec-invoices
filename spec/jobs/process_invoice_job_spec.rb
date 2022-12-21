# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessInvoiceJob, type: :job do
  let(:branch_office) do
    BranchOffice.create!(name: 'Sucursal 1', number: 1, city: 'Santa Cruz', company_id: company.id)
  end
  let(:invoice_status) { InvoiceStatus.create!(description: 'Good') }
  let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }
  let(:invoice) { build(:invoice, branch_office: branch_office, invoice_status: invoice_status) }
  let(:economic_activity) { create(:economic_activity, company: company) }
  before { create(:point_of_sale, branch_office: branch_office) }
  let(:contingency) { create(:contingency, point_of_sale: point_of_sale) }

  describe '#perform_later' do
    before { create(:payment_method) }

    before(:each) do
      invoice.payments.build(mount: 1, payment_method_id: 1)
      invoice.save
    end
    it 'process invoice' do
      point_of_sale = branch_office.point_of_sales.find_by(code: invoice.point_of_sale)
      ActiveJob::Base.queue_adapter = :test
      expect do
        SendCancelInvoicesJob.perform_later(invoice, point_of_sale, point_of_sale)
      end.to have_enqueued_job
    end
  end
end
