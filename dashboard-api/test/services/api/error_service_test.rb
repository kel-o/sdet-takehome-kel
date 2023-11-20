require "test_helper"

class Api::ErrorServiceTest < ActiveSupport::TestCase
  include Api::ErrorService

  def setup
    @calendar_service_error_response = "{\"message\": \"No events found for user_id [1]\"}"
    @billing_service_error_response = "{\"message\": \"No subscription found for user_id [1]\"}"
    @user_service_error_response = "{\"message\":\"User not found\"}"
    @external_api_error_response = Net::HTTPResponse.new(1.0, "404", "Not Found")
  end

  def test_calendar_service_error
    @external_api_error_response.stubs(:body).returns(@calendar_service_error_response)
    error = Api::ErrorService::ApiError.new(@external_api_error_response.code, @external_api_error_response.body)
    assert_equal @calendar_service_error_response, error.message
  end

  def test_billing_service_error
    @external_api_error_response.stubs(:body).returns(@billing_service_error_response)
    error = Api::ErrorService::ApiError.new(@external_api_error_response.code, @external_api_error_response.body)
    assert_equal @billing_service_error_response, error.message
  end

  def test_user_service_error
    @external_api_error_response.stubs(:body).returns(@user_service_error_response)
    error = Api::ErrorService::ApiError.new(@external_api_error_response.code, @external_api_error_response.body)
    assert_equal @user_service_error_response, error.message
  end
end
