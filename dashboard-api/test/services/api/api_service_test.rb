require "test_helper"

class ApiServiceTest < ActiveSupport::TestCase
  def setup
    @endpoint = "http://www.example.com"
    @api_service = Api::ApiService.new(@endpoint)
    @http_instance = Net::HTTP.new(@endpoint, 80)
  end

  def test_get
    response = Net::HTTPOK.new(1.0, 200, "OK")

    Net::HTTP.stubs(:new).returns(@http_instance)
    @http_instance.stubs(:get).returns(response)

    assert_equal response, @api_service.get
  end

  def test_with_net_read_timeout
    Net::HTTP.stubs(:new).returns(@http_instance)
    response = Net::ReadTimeout.new("error")
    response.stubs(:body).returns("body")

    @http_instance.stubs(:get).raises(response)

    assert_equal Api::ErrorService::ApiError.new("500", "error"), @api_service.get
  end

  def test_with_net_open_timeout
    Net::HTTP.stubs(:new).returns(@http_instance)
    response = Net::OpenTimeout.new("error")
    response.stubs(:body).returns("body")

    @http_instance.stubs(:get).raises(response)

    assert_equal Api::ErrorService::ApiError.new("500", "error"), @api_service.get
  end

  def test_get_with_stanard_error
    Net::HTTP.stubs(:new).returns(@http_instance)

    @http_instance.stubs(:get).raises(StandardError.new("error"))
    assert_equal Api::ErrorService::ApiError.new("500", "error"), @api_service.get
  end
end
