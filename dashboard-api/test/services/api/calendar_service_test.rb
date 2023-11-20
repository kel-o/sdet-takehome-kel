require "test_helper"

class Api::CalendarServiceTest < ActiveSupport::TestCase
  def setup
    @calendar_service = Api::CalendarService.new(1)
    @expected_uri = URI.parse("http://calendar-service:8000/events?user_id=1")
    @success_response_body = "{\"events\":[{\"id\":1,\"name\":\"Hangout\",\"duration\":30,\"date\":\"10/1/2023, 12:00:02 PM\",\"attendees\":2,\"timeZone\":\"America/New_York\"},{\"id\":2,\"name\":\"Pre-Screen\",\"duration\":60,\"date\":\"9/29/2023, 1:00:02 PM\",\"attendees\":3,\"timeZone\":\"America/Chicago\"},{\"id\":3,\"name\":\"Group Interview\",\"duration\":120,\"date\":\"9/30/2023, 2:00:02 PM\",\"attendees\":3,\"timeZone\":\"America/Denver\"},{\"id\":4,\"name\":\"1on1\",\"duration\":60,\"date\":\"10/8/2023, 9:00:02 AM\",\"attendees\":2,\"timeZone\":\"America/Los_Angeles\"}]}"
    @failure_response_body = "{\"message\":\"No events found for user_id [1]\"}"
    @parsed_success_response = JSON.parse(@success_response_body)
    @parsed_failure_response = JSON.parse(@failure_response_body)
  end

  def test_successful_get_events
    success_response = Net::HTTPOK.new(1.0, "200", "OK")
    success_response.stubs(:body).returns(@success_response_body)

    Api::ApiService.any_instance.stubs(:get).returns(success_response)

    assert_equal @parsed_success_response, @calendar_service.get_events
  end

  # This cannot fail because the calendar service has a hard-coded response
  def test_get_subscription_error
    failure_response = Net::HTTPResponse.new(1.0, "404", "Not Found")
    failure_response.stubs(:body).returns(@failure_response_body)

    Api::ApiService.any_instance.stubs(:get).returns(failure_response)
    assert Api::ErrorService::ApiError, @calendar_service.get_events
  end
end
