require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "active_storage/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CorrespondenceToolPublic
  class Application < Rails::Application
    # Use AES-256-GCM authenticated encryption for encrypted cookies.
    # Also, embed cookie expiry in signed or encrypted cookies for increased security.
    #
    # This option is not backwards compatible with earlier Rails versions.
    # It's best enabled when your entire app is migrated and stable on 5.2.
    #
    # Existing cookies will be converted on read then written with the new scheme.
    config.action_dispatch.use_authenticated_cookie_encryption = true

    # Use AES-256-GCM authenticated encryption as default cipher for encrypting messages
    # instead of AES-256-CBC, when use_authenticated_message_encryption is set to true.
    config.active_support.use_authenticated_message_encryption = true

    # Add default protection from forgery to ActionController::Base instead of in
    # ApplicationController.
    config.action_controller.default_protect_from_forgery = true

    # Use SHA-1 instead of MD5 to generate non-sensitive digests, such as the ETag header.
    config.active_support.hash_digest_class = ::Digest::SHA1

    # Make `form_with` generate id attributes for any generated HTML tags.
    config.action_view.form_with_generates_ids = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.generators do |g|
      g.factory_bot false
    end

    ActionView::Base.default_form_builder = GovukElementsFormBuilder::FormBuilder
  end
end
