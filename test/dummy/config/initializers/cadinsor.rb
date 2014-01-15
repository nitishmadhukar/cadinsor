# Cadinsor Initializer - Generated on January 15, 2014 23:48
# Please visit github.com/lewstherin/cadinsor for more information on this initializer.

require 'cadinsor'
# Cadinsor Configuration Options
  # # Set the api key expiry time.
  # # If this value is set, any key that is generated will stop being valid after 5 minutes
  Cadinsor::Engine.config.key_expiry_time_in_mins = 99999
  # # Set the value of the client app id field name in params.
  # # If set to :app_id (defaults to :client_app_id), Cadinsor will look for the client application id in params[:app_id]
  Cadinsor::Engine.config.client_app_id_param_name = :app_id
  # # Set the value of the field name of the api key in params.
  # # If set to :key, Cadinsor will look for the api key in params[:key]
  Cadinsor::Engine.config.api_key_param_name = :key
  # # Set the value of the field name of the request signature in params.
  # # If set to :signature, Cadinsor will look for the request signature in params[:signature]
  # Cadinsor::Engine.config.request_signature_param_name = :signature

# Include Cadinsor methods in the application controller

class ApplicationController < ActionController::Base
  include Cadinsor::Extensions
  # When a request fails the cadinsor checks, it raises the Request Error exception
  # The default behaviour redirects the request to a json/xml error page, with the reason for failure
  # Edit this block if you would like the exception to be handled differently.
  rescue_from Cadinsor::Extensions::RequestError do |exception_object|
    cadinsor_rescue(exception_object.message)
  end
end
