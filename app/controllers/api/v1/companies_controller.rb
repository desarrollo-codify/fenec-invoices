# frozen_string_literal: true

module Api
  module V1
    class CompaniesController < ApplicationController
      # before_action :authenticate_user!
      # before_action :super_admin_only, only: %i[index destroy]
      before_action :set_company, except: %i[index update_settings logo create confirm_email]
      before_action :set_parent_company, only: %i[update_settings]

      # GET /companies
      def index
        @companies = Company.all
        render json: @companies.map { |company|
                       if company.logo.attached?
                         company.as_json.merge(
                           logo: url_for(company.logo)
                         )
                       else
                         company.as_json
                       end
                     }
      end

      # GET /companies/1
      def show
        @company = Company.includes(:economic_activities, :company_setting, :page_size, :invoice_types, :measurements, :modality,
                                    :environment_type, :document_sector_types, :payment_methods, branch_offices: :point_of_sales)
                          .find(params[:id])
        result = @company.as_json(except: %i[created_at updated_at],
                                  include: [{ economic_activities: { except: %i[created_at
                                                                                updated_at company_id] } },
                                            branch_offices: { include: { point_of_sales: { only: %i[id name code] } },
                                                              except: %i[created_at updated_at company_id] },
                                            company_setting: { except: %i[created_at updated_at] },
                                            page_size: { only: %i[description] },
                                            invoice_types: { only: %i[id description] },
                                            document_sector_types: { only: %i[id description] },
                                            measurements: { only: %i[id description] },
                                            payment_methods: { only: %i[id code description] },
                                            modality: { only: %i[description] },
                                            environment_type: { only: %i[description] }])

        result = result.merge(logo: url_for(@company.logo)) if @company.logo&.attached?
        render json: result
      end

      # POST /companies
      def create
        @company = Company.new(company_params)

        if @company.save
          render json: @company, status: :created
        else
          render json: @company.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /companies/1
      def update
        if @company.update(company_params)
          @company.logo.attach(company_params[:logo]) if company_params[:logo]
          render json: @company
        else
          render json: @company.errors, status: :unprocessable_entity
        end
      end

      # DELETE /companies/1
      def destroy
        @company.destroy
      end

      # GET /companies/1/logo
      def logo
        company = Company.find(params[:id])

        if company&.logo&.attached?
          render json: url_for(company.logo)
        else
          head :not_found
        end
      end

      # POST /companies/1/settings
      def update_settings
        settings = @company.company_setting
        settings.update(setting_params)
        settings.update(mail_verification: false)
        settings.update(confirm_token: SecureRandom.urlsafe_base64.to_s) if settings.confirm_token.blank?

        render json: settings
      end

      # GET /companies/1/cuis_codes
      def cuis_codes
        response = []
        @company.branch_offices.each do |branch_office|
          branch_office_record = {
            id: branch_office.id,
            name: branch_office.name,
            number: branch_office.number,
            codes: []
          }

          branch_office.point_of_sales.each do |pos|
            cuis_code = branch_office.cuis_codes.by_pos(pos.code).active.last
            branch_office_record[:codes] << {
              type: 'cuis',
              point_of_sale: pos.code,
              code: cuis_code.present? ? cuis_code.code : '',
              end_date: cuis_code.present? ? cuis_code.expiration_date : nil,
              current_number: cuis_code.present? ? cuis_code.current_number : 0
            }
            cufd_code = branch_office.daily_codes.by_pos(pos.code).active.last
            branch_office_record[:codes] << {
              type: 'cufd',
              point_of_sale: pos.code,
              code: cufd_code.present? ? cufd_code.code : '',
              end_date: cufd_code.present? ? cufd_code.end_date : nil,
              current_number: 0
            }
          end
          response << branch_office_record
        end
        render json: response, status: :ok
      end

      def contingencies
        @contingencies = Contingency.includes(:significative_event, point_of_sale: :branch_office)
                                    .joins(point_of_sale: :branch_office)
                                    .where('branch_offices.company_id = ?', @company.id)
        render json: @contingencies.as_json(include: [
                                              { significative_event: { except: %i[created_at updated_at] } },
                                              {
                                                point_of_sale: { include: { branch_office: { only: %i[id name code] } },
                                                                 except: %i[created_at updated_at company_id] }
                                              }
                                            ])
      end

      def product_codes
        @product_codes = @company.product_codes.includes(:economic_activity).order(:description)

        render json: @product_codes.map { |product|
                       product.as_json(except: %i[created_at updated_at])
                              .merge(
                                economic_activity_code: product.economic_activity.code
                              )
                     }
      end

      def invoices
        @invoices = @company.invoices.includes(:branch_office, :invoice_status, :invoice_details).descending
        render json: @invoices.as_json(include: [{ branch_office: { only: %i[id number name] } },
                                                 { invoice_status: { only: %i[id description] } },
                                                 { invoice_details: { except: %i[created_at updated_at] } }])
      end

      # POST /companies/1/add_invoice_type
      def add_invoice_types
        invoice_type_ids = params[:invoice_type_ids]
        invoice_types = InvoiceType.find(invoice_type_ids)
        @company.invoice_types << invoice_types

        render json: @company.invoice_types
      end

      # POST /companies/1/add_document_sector
      def add_document_sector_types
        document_sector_type_ids = params[:document_sector_type_ids]
        document_sector_types = DocumentSectorType.find(document_sector_type_ids)
        @company.document_sector_types << document_sector_types

        render json: @company.document_sector_types
      end

      # POST /companies/1/add_measurement
      def add_measurements
        measurement_ids = params[:measurements_ids]
        measurements = Measurement.find(measurement_ids)
        @company.measurements << measurements

        render json: @company.measurements
      end

      # POST /companies/1/add_payment_methods
      def add_payment_methods
        payment_methods_ids = params[:payment_methods_ids]
        payment_methods = PaymentMethod.find(payment_methods_ids)
        @company.payment_methods << payment_methods

        render json: @company.payment_methods
      end

      def remove_invoice_type
        @company.invoice_types.delete(params[:invoice_type_id])

        render json: @company.invoice_types
      end

      def remove_document_sector_type
        @company.document_sector_types.delete(params[:document_sector_type_id])

        render json: @company.document_sector_types
      end

      def remove_measurements
        @company.measurements.delete(params[:measurement_id])

        render json: @company.measurements
      end

      def remove_payment_methods
        @company.payment_methods.delete(params[:payment_method_id])

        render json: @company.payment_methods
      end

      def mail_test
        unless @company.company_setting.present?
          return render json: { message: 'No se ha configurado ningun correo para la empresa.' },
                        status: :unprocessable_entity
        end

        MailTestMailer.with(email: params[:email], company: @company).send_mail.deliver_later

        render json: { message: "Si recibió un correo de prueba en #{params[:email]}, presione el botón de confirmación." }
      end

      def find_currency
        date = params[:date].to_date

        currency = @company.accounting_transactions.find_by(date: date).currency

        unless currency.present?
          render json: { message: "No se ha encontrado un tipo de cambio en la fecha: #{date}." },
                 status: :unprocessable_entity
        end

        render json: currency
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_company
        @company = Company.find(params[:id])
      end

      def set_parent_company
        @company = Company.find(params[:company_id])
      end

      # Only allow a list of trusted parameters through.
      def company_params
        params.require(:company).permit(:name, :nit, :address, :phone, :logo, :page_size_id, :environment_type_id, :modality_id)
      end

      def setting_params
        params.require(:company_setting).permit(:address, :port, :domain, :user_name, :password)
      end

      def super_admin_only
        render json: { message: 'Only admin users.' }, status: :unauthorized unless current_user.super_admin?
      end
    end
  end
end
