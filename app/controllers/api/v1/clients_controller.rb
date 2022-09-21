# frozen_string_literal: true

module Api
  module V1
    class ClientsController < ApplicationController
      before_action :set_company, only: %i[index create]
      before_action :set_client, only: %i[update destroy]

      def index
        @clients = @company.clients.all

        render json: @clients
      end

      def create
        @client = @company.clients.build(client_params)
        if @client.save
          render json: @client, status: :created
        else
          render json: @client.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /clients/1
      def update
        if @client.update(client_params)
          @client.logo.attach(client_params[:logo]) if client_params[:logo]
          render json: @client
        else
          render json: @client.errors, status: :unprocessable_entity
        end
      end

      # DELETE /clients/1
      def destroy
        @client.destroy
      end

      private

      def client_params
        params.require(:client).permit(:code, :name, :nit, :phone, :email, :complement, :document_type_id)
      end

      def set_client
        @client = Client.find(params[:id])
      end

      def set_company
        @company = Company.find(params[:company_id])
      end
    end
  end
end
