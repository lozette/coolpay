require 'httparty'
require 'json'

module Utils
  class HTTPAuth

    def initialize(url, username, secret)
      @url = url
      @username = @username
      @secret = @secret
    end

    def get(url)
      headers = signed_request_headers(:get, url)
      response = HTTParty.get(url, headers: headers)
      handle(response)
    end

    def post(url, params = {})
      headers = signed_request_headers(:post, url, params)
      response = HTTParty.post(url, headers: headers, body: params.to_json)
      handle(response)
    end

    def signed_request_headers(http_method, url, params = {})
      params = params.empty? ? '' : params.to_json
      body = { username: @username, apikey: @secret }
      token = HTTParty.post(@url, body)
      headers.merge('Authorization-Bearer' => token)
    end

    private

    def headers
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    end

    def handle(response)
      case response.code
      when 404
        raise NotFound
      when 401
        raise Unauthorized
      when 422
        raise UnprocessableEntity
      else
        response
      end
    end
  end
end
