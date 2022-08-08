class CustomFailure < Devise::FailureApp
  def respond
    api_response
  end

  private
  def api_response
    self.status = 401
    self.content_type = 'application/json'
    # optional - send a message in the response body
    # response.body = { error: i18n_message }.to_json
  end
end