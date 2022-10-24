class Api::V1::CyclesController < ApplicationController
  before_action :set_api_v1_cycle, only: %i[ show update destroy ]

  # GET /api/v1/cycles
  def index
    @api_v1_cycles = Cycle.all

    render json: @api_v1_cycles
  end

  # GET /api/v1/cycles/1
  def show
    render json: @api_v1_cycle
  end

  # POST /api/v1/cycles
  def create
    @api_v1_cycle = Cycle.new(api_v1_cycle_params)

    if @api_v1_cycle.save
      render json: @api_v1_cycle, status: :created, location: @api_v1_cycle
    else
      render json: @api_v1_cycle.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/cycles/1
  def update
    if @api_v1_cycle.update(api_v1_cycle_params)
      render json: @api_v1_cycle
    else
      render json: @api_v1_cycle.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/cycles/1
  def destroy
    @api_v1_cycle.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_cycle
      @api_v1_cycle = Cycle.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def api_v1_cycle_params
      params.fetch(:api_v1_cycle, {})
    end
end
