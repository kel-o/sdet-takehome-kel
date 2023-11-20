require "net/http"
require "uri"

module Api
  class CalendarService
    include Api::ErrorService

    def initialize(user_id)
      @user_id = user_id
    end

    def get_events
      params = { "user_id" => @user_id }

      response = ApiService.new(events_endpoint, params).get

      return ApiError.new(response.code, response.message) unless response.code == "200"
      JSON.parse(response.body)
    end

    private

    def events_endpoint
      "#{Rails.configuration.calendar_service_endpoint}/events"
    end
  end
end
