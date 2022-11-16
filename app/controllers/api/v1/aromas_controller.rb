class Api::V1::AromasController < ApplicationController
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
                                 include: [{ order_details: { except: %i[created_at updated_at] }},
                                             order_customer: { except: %i[created_at updated_at company_id] }])
  end

  def generate
    verify_data(request)
    data = request.body.read

    json_data = JSON.parse data

    if (json_data['location_id'] == 3417309211)
      unless Order.find_by(number: json_data['number'])
        company = Company.first
        order = company.orders.build(order_id: json_data['id'], date: DateTime.now, location_id: json_data['location_id'], number: json_data['number'])
        json_data['line_items'].each do |item|
          order_detail = order.order_details.build(product_id: item['product_id'], title: item['title'], sku: item['sku'], 
              total: item['price'] * 6.96,
              discount: item['discount'].present? ? item['discount'] * 6.96 : 0, 
              quantity: item['quantity'])
        end
        full_name = json_data['customer'] ? json_data['customer']['first_name'] + ' ' + json_data['customer']['last_name'] : "No Customer"
        customer_id = json_data['customer'] ? json_data['customer']['id'] : 0
        email = json_data['customer'] ? json_data['customer']['email'] : ''
        phone = json_data['customer'] ? json_data['customer']['phone'] : ''
        order_customer = order.build_order_customer(name: full_name, email: email, phone: phone, customer_id: customer_id)
        order.save!
      end
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
    hmac_header = request.headers["HTTP_X_SHOPIFY_HMAC_SHA256"]
    verified = verify_webhook(data, hmac_header)
    puts "Webhook verified: #{verified}"

    unless verified 
      render json: {
          status: 403, 
          message: 'nop', 
          data: ''
        }, 
        status: 403
    end
  end

  def verify_webhook(data, hmac_header)
    puts hmac_header
    calculated_hmac = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', SHARED_SECRET, data))
    ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, hmac_header)
  end
end
