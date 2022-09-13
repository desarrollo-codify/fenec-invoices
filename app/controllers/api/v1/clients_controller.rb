# frozen_string_literal: true

module Api
  module V1
    class ClientsController < ApplicationController
      before_action :set_company, only: %i[index create]

      def index
        @clients = @company.clients.all

        render json: @clients
      end

      def create
        @client = @company.clients.build(client_params)
        last_code = Client.where.not(code:nil).last.code
        if @client.save
          @client.update(code: (last_code.to_i + 1).to_s.rjust(5, '0'))
          render json: @client, status: :created
        else
          render json: @client.errors, status: :unprocessable_entity
        end
      end

      private

      def client_params
        params.require(:client).permit(:code, :name, :nit, :phone, :email, :complement, :document_type_id)
      end

      def set_company
        @company = Company.find(params[:company_id])
      end
    end
  end
end
