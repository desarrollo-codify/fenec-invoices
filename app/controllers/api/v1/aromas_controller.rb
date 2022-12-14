# frozen_string_literal: true

module Api
  module V1
    class AromasController < ApplicationController
      SHARED_SECRET = 'ac58ad6b6cda879b66298c0e8d4438f924772c94fdef73fc908855dddf12c148'
      # API_KEY = 'e66194343b7a521549c3dde66eef0358'
      # PASSWORD = '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'
      # SHOP_NAME = 'perfumeria-first'
      # SHOP_URL = "https://#{API_KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com"
      # ShopifyAPI::Base.site = SHOP_URL
      # ShopifyAPI::Base.api_version = '2020-10'

      def index
        @orders = Order.includes(:order_details, :order_customer).all.order(number: :desc)
        render json: @orders.as_json(except: %i[created_at updated_at],
                                     include: [{ order_details: { except: %i[created_at updated_at] } },
                                               order_customer: { except: %i[created_at updated_at company_id] }])
      end

      def generate
        # verify_data(request)
        data = request.body.read

        json_data = JSON.parse data

        unless Order.find_by(number: json_data['order_number'])
          company = Company.first
          total_order = 0
          order = company.orders.build(order_id: json_data['id'], date: DateTime.now, location_id: json_data['location_id'],
                                       number: json_data['order_number'])
          json_data['line_items'].each do |item|
            order.order_details.build(product_id: item['product_id'],
                                      title: item['title'],
                                      sku: item['sku'],
                                      total: (item['price'].to_d * 6.96).round(2),
                                      discount: item['total_discount'].present? ? (item['total_discount'].to_d * 6.96).round(2) : 0,
                                      quantity: item['quantity'])
            total_order += (item['price'].to_d - item['total_discount'].to_d)
          end
          order.total = total_order
          order.total_discount = json_data['total_discounts'].to_d
          full_name = json_data['customer'] ? "#{json_data['customer']['first_name']} #{json_data['customer']['last_name']}" : 'No Customer'
          customer_id = json_data['customer'] ? json_data['customer']['id'] : 0
          email = json_data['customer'] ? json_data['customer']['email'] : ''
          phone = json_data['customer'] ? json_data['customer']['phone'] : ''
          order.build_order_customer(name: full_name, email: email, phone: phone, customer_id: customer_id)
          order.save!

          verify_products(order)
        end

        render status: :ok
      end

      def destroy
        @order = Order.find(params[:id])
        @order.destroy
      end

      private

      def verify_data(request)
        request.body.rewind
        data = request.body.read
        hmac_header = request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
        verified = verify_webhook(data, hmac_header)
        puts "Webhook verified: #{verified}"

        return if verified

        render json: {
                 status: 403,
                 message: 'nop',
                 data: ''
               },
               status: 403
      end

      def verify_webhook(data, hmac_header)
        puts hmac_header
        calculated_hmac = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', SHARED_SECRET, data))
        ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, hmac_header)
      end

      def verify_products(order)
        company = Company.first
        order.order_details.each do |detail|
          product = company.products.find_or_create_by(primary_code: detail.sku) do |p|
            p.title = detail.title
            p.description = detail.title
            p.primary_code = detail.sku
            p.price = detail.total
            # TODO: refactor this
            p.sin_code = company.products.where.not(sin_code: nil).first.sin_code
          end
          product.variants.create!(sku: product.primary_code, price: product.price, compare_price: product.price, cost: 0, title: product.title) if product.persisted?
        end
      end
    end
  end
end
