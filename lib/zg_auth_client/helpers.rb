require 'active_support/concern'
require 'config'

module ZgAuthClient
  module Helpers
    extend ActiveSupport::Concern

    included do
      before_action :check_session
    end

    def current_user
      @current_user ||= ::User.find_by(id: session_user_id)
    end

    def user_signed_in?
      !!current_user
    end

    def sign_in_url
      raise 'Error::Settings: <profile.sign_in_url> is undefined' if Settings.profile.sign_in_url.blank?

      uri = URI.parse(Settings.profile.sign_in_url)

      uri.query = { redirect_url: request.original_url }.to_query

      uri.to_s
    end

    def sign_out_url
      raise 'Error::Settings: <profile.sign_out_url> is undefined' if Settings.profile.sign_out_url.blank?

      uri = URI.parse(Settings.profile.sign_out_url)

      uri.query = { redirect_url: request.original_url }.to_query

      uri.to_s
    end

    private

    def session_user_id
      session['warden.user.user.key'].try(:first).try(:first)
    end

    def check_session
      if session['warden.user.user.session']
        last_request_at = session['warden.user.user.session']['last_request_at']
        timeout_in = current_user.timeout_in.to_i rescue 7.days
        if Time.zone.now.to_i - last_request_at > timeout_in
          session.clear
        else
          session['warden.user.user.session']['last_request_at'] = Time.zone.now.to_i

          current_user.activity_notify if current_user
        end
      end
    end
  end
end

ActiveSupport.on_load :action_controller do
  include ZgAuthClient::Helpers
  if respond_to? :helper_method
    helper_method :current_user, :user_signed_in?, :sign_in_url, :sign_out_url
  end
end
