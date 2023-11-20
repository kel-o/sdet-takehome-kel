require "test_helper"

class SummaryControllerTest < ActionDispatch::IntegrationTest
  def setup
    user_service = Api::UserService.any_instance
    billing_service = Api::BillingService.any_instance
    calendar_service = Api::CalendarService.any_instance
    user_service.stubs(:get_user).returns({ "id" => 1, "first_name" => "Michael", "last_name" => "Scott" })
    billing_service.stubs(:get_subscription).returns({ "user_id" => 1, "renewal_date" => "11/03/2023", "price_cents" => 1500 })
    calendar_service.stubs(:get_events).returns({ "events" => [
      { "id" => 1, "name" => "Hangout", "duration" => 30, "date" => "10/1/2023, 12:00:02 PM", "attendees" => 2, "timeZone" => "America/New_York" },
      { "id" => 2, "name" => "Pre-Screen", "duration" => 60, "date" => "9/29/2023, 1:00:02 PM", "attendees" => 3, "timeZone" => "America/Chicago" },
      { "id" => 3, "name" => "Group Interview", "duration" => 120, "date" => "9/30/2023, 2:00:02 PM", "attendees" => 3, "timeZone" => "America/Denver" },
      { "id" => 4, "name" => "1on1", "duration" => 60, "date" => "10/8/2023, 9:00:02 AM", "attendees" => 2, "timeZone" => "America/Los_Angeles" },
      { "id" => 5, "name" => "1on1", "duration" => 60, "date" => "10/10/2023, 12:00:02 PM", "attendees" => 2, "timeZone" => "America/Chicago" },
      { "id" => 6, "name" => "1on1", "duration" => 60, "date" => "10/10/2023, 12:00:02 PM", "attendees" => 2, "timeZone" => "GMT" },
      { "id" => 7, "name" => "1on1", "duration" => 60, "date" => "10/10/2023, 12:00:02 PM", "attendees" => 2, "timeZone" => "Europe/London" },
      { "id" => 8, "name" => "Meeting in India", "duration" => 30, "date" => "10/1/2023, 5:30:02 PM", "attendees" => 2, "timeZone" => "Asia/Kolkata" },
      { "id" => 12, "name" => "Midnight Meeting in NY", "duration" => 30, "date" => "10/1/2023, 12:00:00 AM", "attendees" => 3, "timeZone" => "America/New_York" },
    ] })

    local_time_zone = "America/New_York"
    current_time = "10/1/2023, 12:00:02 PM"
    local_time = Time.strptime(current_time, "%m/%d/%Y, %I:%M:%S %p").in_time_zone(local_time_zone)
    mocked_utc_time = local_time.utc
    Time.stubs(:now).returns(mocked_utc_time)

    local_time = Time.strptime(current_time, "%m/%d/%Y, %I:%M:%S %p").in_time_zone(local_time_zone)
    mocked_utc_time = local_time.utc
    Time.stubs(:now).returns(mocked_utc_time)
  end

  def test_successful_summary
    user_id = 1
    expected_response = {
      "errors" => [],
      "summary" => {
        "user_name" => "Michael Scott",
        "number_of_meetings_within_last_week" => 4,
        "next_meeting" => {
          "name" => "Meeting in India",
          "date" => "10/1/2023, 5:30:02 PM",
          "time_zone" => "Asia/Kolkata",
          "duration" => "30 minutes",
          "attendees" => 2,
        },
        "subscription_cost" => "$15.00",
        "days_until_subscription_renewal" => "33 days left",
      },
    }
    get "/summary/#{user_id}"
    assert_response :success
    assert_equal expected_response, JSON.parse(response.body)
  end

  def test_user_service_failure
    user_service_failure = Api::ErrorService::ApiError.new("404", "User not found")
    Api::UserService.any_instance.stubs(:get_user).returns(user_service_failure)

    user_id = 1
    get "/summary/#{user_id}"

    assert_response :unprocessable_entity
    assert_equal({ "errors" => ["User service error: User not found"] }, JSON.parse(response.body))
  end

  def test_billing_service_failure
    billing_service_failure = Api::ErrorService::ApiError.new("404", "AHGHH!")
    Api::BillingService.any_instance.stubs(:get_subscription).returns(billing_service_failure)

    user_id = 1
    get "/summary/#{user_id}"

    assert_response :success

    expected_response = {
      "errors" => ["Billing service error: AHGHH!"],
      "summary" => {
        "user_name" => "Michael Scott",
        "number_of_meetings_within_last_week" => 4,
        "next_meeting" => { "name" => "Meeting in India", "date" => "10/1/2023, 5:30:02 PM", "time_zone" => "Asia/Kolkata", "duration" => "30 minutes", "attendees" => 2 },
        "subscription_cost" => nil,
        "days_until_subscription_renewal" => nil,
      },
    }

    assert_equal expected_response, JSON.parse(response.body)
  end

  def test_calendar_service_failure
    calendar_service_failure = Api::ErrorService::ApiError.new("404", "AHGHH!")
    Api::CalendarService.any_instance.stubs(:get_events).returns(calendar_service_failure)

    user_id = 1
    get "/summary/#{user_id}"

    assert_response :success
    expected_response = {
      "errors" => ["Calendar service error: AHGHH!"],
      "summary" => {
        "user_name" => "Michael Scott",
        "number_of_meetings_within_last_week" => 0,
        "next_meeting" => nil,
        "subscription_cost" => "$15.00",
        "days_until_subscription_renewal" => "33 days left",
      },
    }
  end

  def test_billing_and_calendar_service_failure
    billing_service_failure = Api::ErrorService::ApiError.new("404", "AHGHH!")
    Api::BillingService.any_instance.stubs(:get_subscription).returns(billing_service_failure)

    calendar_service_failure = Api::ErrorService::ApiError.new("404", "AHGHH!")
    Api::CalendarService.any_instance.stubs(:get_events).returns(calendar_service_failure)

    user_id = 1
    get "/summary/#{user_id}"

    assert_response :success
    expected_response = {
      "errors" => ["Billing service error: AHGHH!", "Calendar service error: AHGHH!"],
      "summary" => {
        "user_name" => "Michael Scott",
        "number_of_meetings_within_last_week" => 0,
        "next_meeting" => nil,
        "subscription_cost" => nil,
        "days_until_subscription_renewal" => nil,
      },
    }
  end
end
