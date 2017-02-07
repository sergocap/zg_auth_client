class Permission < ActiveRecord::Base
  include ZgAuthClient::Permission

  acts_as_auth_client_permission roles: [:admin]
end
