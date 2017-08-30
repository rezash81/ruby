require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'
# require 'phusion_passenger/rack/out_of_band_gc'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Uasco
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Tehran'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = :fa
    config.i18n.enforce_available_locales = false
    I18n.enforce_available_locales = false

    # config.middleware.use PhusionPassenger::Rack::OutOfBandGc, 1

    # PhusionPassenger.on_event(:oob_work) do
    #   # Phusion Passenger has told us that we're ready to perform OOB work.
    #   t0 = Time.now
    #   GC.start
    #   Rails.logger.info "Out-Of-Bound GC finished in #{Time.now - t0} sec"
    # end

  end
end


