class Api::V1::EconomicActivitiesController < ApplicationController
  before_action :set_economic_activity, only: %i[ show update destroy ]
  before_action :set_company, only: %i[ index ]
  # TODO: only index action?

  # GET /api/v1/companies/:company_id/economic_activities
  def index
    @economic_activities = @company.economic_activities.all

    render json: @economic_activities
  end

  private
    def set_company
      @company = Company.find(params[:company_id])
    end
end
