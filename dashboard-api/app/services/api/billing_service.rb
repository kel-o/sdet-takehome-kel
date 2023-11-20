require "net/http"
require "uri"

module Api
  class BillingService
    include Api::ErrorService

    def initialize(user_id)
      @user_id = user_id
    end

    def get_subscription
      params = { "user_id" => @user_id }

      response = ApiService.new(subscriptions_endpoint, params).get

      return Api::ErrorService::ApiError.new(response.code, response.message) unless response.code == "200"
      JSON.parse(response.body)
    end

    private

    def subscriptions_endpoint
      "#{Rails.configuration.billing_service_endpoint}/subscriptions"
    end
  end
end
