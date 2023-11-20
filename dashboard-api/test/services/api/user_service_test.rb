require "test_helper"

class Api::UserServiceTest < ActiveSupport::TestCase
  def setup
    @user_service = Api::UserService.new(1)
    @expected_uri = URI.parse("http://user-service:8000/users/1")
    @success_response_body = "{\"id\":1,\"first_name\":\"Michael\",\"last_name\":\"Scott\"}"
    @failure_response_body = "{\"message\":\"User not found\"}"
    @parsed_success_response = JSON.parse(@success_response_body)
    @parsed_failure_response = JSON.parse(@failure_response_body)
  end

  def test_successful_get_user
    success_response = Net::HTTPOK.new(1.0, "200", "OK")
    success_response.stubs(:body).returns(@success_response_body)
    Net::HTTP.stubs(:get_response).with(@expected_uri).returns(success_response)

    Api::ApiService.any_instance.stubs(:get).returns(success_response)
    assert_equal @parsed_success_response, @user_service.get_user
  end

  def test_failed_get_user
    failure_response = Net::HTTPResponse.new(1.0, "404", "Not Found")
    failure_response.stubs(:body).returns(@failure_response_body)

    Api::ApiService.any_instance.stubs(:get).returns(failure_response)
    assert Api::ErrorService::ApiError, @user_service.get_user
  end
end
