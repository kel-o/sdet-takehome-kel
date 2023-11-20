require "net/http"
require "uri"

module Api
  class ApiService
    def initialize(url, params = {})
      @uri = URI.parse(url)
      @uri.query = URI.encode_www_form(params)
    end

    def get
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.open_timeout = 5
      http.read_timeout = 5

      response = http.get(@uri.request_uri)

      return Api::ErrorService::ApiError.new(response.code, "The External API is currently unavailable") if response.is_a?(Net::HTTPServerError)

      response
    rescue Net::ReadTimeout, Net::OpenTimeout => e
      Api::ErrorService::ApiError.new("500", e.message)
    rescue StandardError => e
      Api::ErrorService::ApiError.new("500", e.message)
    end
  end
end
