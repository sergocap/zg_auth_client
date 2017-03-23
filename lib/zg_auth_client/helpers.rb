require 'active_support/concern'

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
    helper_method :current_user, :user_signed_in?
  end
end
