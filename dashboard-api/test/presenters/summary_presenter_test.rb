require "test_helper"

class SummaryPresenterTest < ActiveSupport::TestCase
  def setup
    @user_data = { "id" => 1, "first_name" => "Michael", "last_name" => "Scott" }
    @billing_data = { "user_id" => 1, "renewal_date" => "11/03/2023", "price_cents" => 1500 }
    @calendar_data = { "events" => [
      { "id" => 1, "name" => "Hangout", "duration" => 30, "date" => "10/1/2023, 12:00:02 PM", "attendees" => 2, "timeZone" => "America/New_York" },
      { "id" => 2, "name" => "Pre-Screen", "duration" => 60, "date" => "9/29/2023, 1:00:02 PM", "attendees" => 3, "timeZone" => "America/Chicago" },
      { "id" => 3, "name" => "Group Interview", "duration" => 120, "date" => "9/30/2023, 2:00:02 PM", "attendees" => 3, "timeZone" => "America/Denver" },
      { "id" => 4, "name" => "1on1", "duration" => 60, "date" => "10/8/2023, 9:00:02 AM", "attendees" => 2, "timeZone" => "America/Los_Angeles" },
      { "id" => 5, "name" => "1on1", "duration" => 60, "date" => "10/10/2023, 12:00:02 PM", "attendees" => 2, "timeZone" => "America/Chicago" },
      { "id" => 6, "name" => "1on1", "duration" => 60, "date" => "10/10/2023, 12:00:02 PM", "attendees" => 2, "timeZone" => "GMT" },
      { "id" => 7, "name" => "1on1", "duration" => 60, "date" => "10/10/2023, 12:00:02 PM", "attendees" => 2, "timeZone" => "Europe/London" },
      { "id" => 8, "name" => "Meeting in India", "duration" => 30, "date" => "10/1/2023, 5:30:02 PM", "attendees" => 2, "timeZone" => "Asia/Kolkata" },
      { "id" => 12, "name" => "Midnight Meeting in NY", "duration" => 30, "date" => "10/1/2023, 12:00:00 AM", "attendees" => 3, "timeZone" => "America/New_York" },

    ] }
    @expected_last_weeks_meetings = [
      { "id" => 2, "name" => "Pre-Screen", "duration" => 60, "date" => "9/29/2023, 1:00:02 PM", "attendees" => 3, "timeZone" => "America/Chicago" },
      { "id" => 3, "name" => "Group Interview", "duration" => 120, "date" => "9/30/2023, 2:00:02 PM", "attendees" => 3, "timeZone" => "America/Denver" },
      { "id" => 8, "name" => "Meeting in India", "duration" => 30, "date" => "10/1/2023, 5:30:02 PM", "attendees" => 2, "timeZone" => "Asia/Kolkata" },
      { "id" => 12, "name" => "Midnight Meeting in NY", "duration" => 30, "date" => "10/1/2023, 12:00:00 AM", "attendees" => 3, "timeZone" => "America/New_York" },
    ]

    @presenter = SummaryPresenter.new(@user_data, @billing_data, @calendar_data)
    local_time_zone = "America/New_York"
    current_time = "10/1/2023, 12:00:02 PM"
    local_time = Time.strptime(current_time, "%m/%d/%Y, %I:%M:%S %p").in_time_zone(local_time_zone)
    mocked_utc_time = local_time.utc
    Time.stubs(:now).returns(mocked_utc_time)

    local_time = Time.strptime(current_time, "%m/%d/%Y, %I:%M:%S %p").in_time_zone(local_time_zone)
    mocked_utc_time = local_time.utc
    Time.stubs(:now).returns(mocked_utc_time)
  end

  def test_present
    expected = {
      user_name: "Michael Scott",
      number_of_meetings_within_last_week: 4,
      next_meeting: {
        name: "Meeting in India",
        date: "10/1/2023, 5:30:02 PM",
        time_zone: "Asia/Kolkata",
        duration: "30 minutes",
        attendees: 2,
      },
      subscription_cost: "$15.00",
      days_until_subscription_renewal: "33 days left",
    }

    assert_equal expected, @presenter.present
  end

  def test_user_name
    assert_equal "Michael Scott", @presenter.user_name
  end

  def test_last_weeks_meetings
    assert_equal @expected_last_weeks_meetings, @presenter.last_weeks_meetings
  end

  def test_price_to_dollars
    assert_equal "$15.00", @presenter.price_to_dollars
    assert_equal "$0.55", SummaryPresenter.new(@user_data, @billing_data.merge("price_cents" => 55), @calendar_data).price_to_dollars
    assert_equal "$0.05", SummaryPresenter.new(@user_data, @billing_data.merge("price_cents" => 5), @calendar_data).price_to_dollars
    assert_equal "$0.00", SummaryPresenter.new(@user_data, @billing_data.merge("price_cents" => 0), @calendar_data).price_to_dollars
    assert_equal "$-0.05", SummaryPresenter.new(@user_data, @billing_data.merge("price_cents" => -5), @calendar_data).price_to_dollars
  end

  def test_next_meeting
    next_meeting = { "id" => 8, "name" => "Meeting in India", "duration" => 30, "date" => "10/1/2023, 5:30:02 PM", "attendees" => 2, "timeZone" => "Asia/Kolkata" }
    expected = {
      name: "Meeting in India",
      date: "10/1/2023, 5:30:02 PM",
      time_zone: "Asia/Kolkata",
      duration: "30 minutes",
      attendees: 2,
    }

    assert_equal expected, @presenter.next_meeting
    assert_equal "No upcoming meetings", SummaryPresenter.new(@user_data, @billing_data, { "events" => [] }).next_meeting
  end

  def test_days_left_message
    assert_equal "33 days left", @presenter.days_left_message
    assert_equal "Subscription renews today!", SummaryPresenter.new(@user_data, @billing_data.merge("renewal_date" => "10/1/2023"), @calendar_data).days_left_message
    assert_equal "Your subscription expired 3 days ago", SummaryPresenter.new(@user_data, @billing_data.merge("renewal_date" => "9/28/2023"), @calendar_data).days_left_message
  end

  def test_days_until_subscription_renewal
    assert_equal 33, @presenter.days_until_subscription_renewal
    assert_equal -3, SummaryPresenter.new(@user_data, @billing_data.merge("renewal_date" => "9/28/2023"), @calendar_data).days_until_subscription_renewal
    assert_equal 0, SummaryPresenter.new(@user_data, @billing_data.merge("renewal_date" => "10/1/2023"), @calendar_data).days_until_subscription_renewal
  end
end
