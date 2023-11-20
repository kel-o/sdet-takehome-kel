require "test_helper"

class Api::BillingServiceTest < ActiveSupport::TestCase
  def setup
    @billing_service = Api::BillingService.new(1)
    @expected_uri = URI.parse("http://billing-service:8000/subscriptions?user_id=1")
    @success_response_body = "{\"user_id\": 1, \"renewal_date\": \"11/03/2023\", \"price_cents\": 1500}"
    @failure_response_body = "{\"message\": \"No subscription found for user_id [1]\"}"
    @parsed_success_response = JSON.parse(@success_response_body)
    @parsed_failure_response = JSON.parse(@failure_response_body)
  end

  def test_successful_get_subscription
    success_response = Net::HTTPOK.new(1.0, "200", "OK")
    success_response.stubs(:body).returns(@success_response_body)

    Api::ApiService.any_instance.stubs(:get).returns(success_response)

    assert_equal @parsed_success_response, @billing_service.get_subscription
  end

  def test_failed_get_subscription
    failure_response = Net::HTTPResponse.new(1.0, "404", "Not Found")
    failure_response.stubs(:body).returns(@failure_response_body)

    Api::ApiService.any_instance.stubs(:get).returns(failure_response)
    assert Api::ErrorService::ApiError, @billing_service.get_subscription
  end
end
