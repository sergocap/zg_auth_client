class User
  include ZgAuthClient::User

  acts_as_auth_client_user

  def app_name
    'change_this_to_app_name'
  end
end
