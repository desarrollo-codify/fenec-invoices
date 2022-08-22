class Api::V1::MeasurementTypesController < ApplicationController
	# GET /api/v1/measurement_types
	def index
		@measurement_types = Legend.all

		render json: @measurement_types
	end
end
