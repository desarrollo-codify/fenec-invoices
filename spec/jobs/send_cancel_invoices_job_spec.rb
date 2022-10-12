# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendCancelInvoicesJob, type: :job do
  let(:point_of_sale) { create(:point_of_sale) }

  let(:contingency) { create(:contingency, point_of_sale: point_of_sale) }

  describe '#perform_later' do
    it 'send cancel invoices' do
      ActiveJob::Base.queue_adapter = :test
      expect do
        SendCancelInvoicesJob.perform_later(contingency)
      end.to have_enqueued_job
    end
  end
end
