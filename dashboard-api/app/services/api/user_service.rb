require "net/http"
require "uri"

module Api
  class UserService
    include Api::ErrorService

    def initialize(user_id)
      @user_id = user_id
    end

    def get_user
      response = ApiService.new(endpoint).get

      return ApiError.new(response.code, response.message) unless response.code == "200"
      JSON.parse(response.body)
    end

    private

    def endpoint
      "#{Rails.configuration.user_service_endpoint}/users/#{@user_id}"
    end
  end
end
