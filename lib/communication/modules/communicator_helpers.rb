# frozen_string_literal: true

# Communicator helpers
module CommunicatorHelpers
  def check_unauthorized(status, url)
    return unless status == 401 && auth_call?(url)

    raise InvalidCredentialsException.new, 'Login failed! Please check your credentials.'
  end

  def check_not_found(status)
    raise APIResourceNotFoundException.new, 'API resource not found.' if status == 404
  end

  def check_not_success(status)
    raise NotSuccessStatusCodeException.new, 'Not success response.' if status / 200 != 1
  end

  def handle_success(body)
    json_body = Utilities.valid_json?(body) ? parse_json(body) : '{}'
    yield(json_body) if block_given?
  end

  def should_relogin(res)
    !relogin_performed && !auth_call?(res.env.url.to_s) && res.status == 401
  end

  def auth_call?(path)
    path.include?('/rest/auth/')
  end

  def relogin
    # read credentials from configuration file configuration
    Utilities.remove_cookie
    conn.headers.delete('Cookie')
    SessionManager.new(CredentialsConfiguration.new.login_credentials).login(true)
    self.relogin_performed = true
    last_call.call(last_proc)
  end
end
