# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FenecInvoices
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.session_store :cookie_store, key: '_interslice_session'

    # Required for all session management (regardless of session_store)
    config.middleware.use ActionDispatch::Cookies

    config.middleware.use config.session_store, config.session_options

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.time_zone = 'La Paz'
    config.active_record.default_timezone = :local

    config.active_storage.variant_processor = :mini_magick

    # rubocop:disable all
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'siat.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        if key == 'default'
          value.each do |v_key, v_value|
            ENV[v_key.to_s] = v_value
          end
        end
      end if File.exists?(env_file)
    end
    # rubocop:enable all
  end
end
