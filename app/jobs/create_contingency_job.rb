# frozen_string_literal: true

class CreateContingencyJob < ApplicationJob
  queue_as :default

  def perform(point_of_sale, start_date, cufd_code, significative_event_id)
    point_of_sale.contingencies.create(start_date: start_date,
                                       cufd_code: cufd_code,
                                       significative_event_id: significative_event_id,
                                       point_of_sale_id: point_of_sale.code)
  end
end
