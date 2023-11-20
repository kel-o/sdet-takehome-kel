class SummaryPresenter
  def initialize(user_data, billing_data, calendar_data)
    @user_data = user_data
    @billing_data = billing_data
    @calendar_data = calendar_data
  end

  def present
    {
      user_name: user_name,
      number_of_meetings_within_last_week: last_weeks_meetings.count,
      next_meeting: next_meeting,
      subscription_cost: price_to_dollars,
      days_until_subscription_renewal: days_left_message,
    }
  end

  def user_name
    "#{@user_data["first_name"]} #{@user_data["last_name"]}"
  end

  def last_weeks_meetings
    return [] unless valid_calendar_data?
    @calendar_data["events"].select do |event|
      to_utc(event) >= 1.week.ago.utc && to_utc(event) <= DateTime.current.utc
    end
  end

  def price_to_dollars
    return nil unless valid_billing_data?
    sprintf("$%.2f", @billing_data["price_cents"] / 100.0)
  end

  def next_meeting
    return nil unless valid_calendar_data?
    return "No upcoming meetings" if future_events.empty?
    next_meeting = future_events.first

    {
      name: next_meeting["name"],
      date: next_meeting["date"],
      time_zone: next_meeting["timeZone"],
      duration: "#{next_meeting["duration"]} minutes",
      attendees: next_meeting["attendees"],
    }
  end

  def days_left_message
    return nil unless valid_billing_data?
    day_or_days = days_until_subscription_renewal == 1 ? "day" : "days"

    if days_until_subscription_renewal > 0
      "#{days_until_subscription_renewal} #{day_or_days} left"
    elsif days_until_subscription_renewal == 0
      "Subscription renews today!"
    else
      "Your subscription expired #{days_until_subscription_renewal.abs} #{day_or_days} ago"
    end
  end

  def days_until_subscription_renewal
    (format_date(@billing_data["renewal_date"]) - Date.current).to_i
  end

  private

  def to_utc(event)
    naive_date = DateTime.strptime(event["date"], "%m/%d/%Y, %I:%M:%S %p")
    localized_date = Time.use_zone(event["timeZone"]) do
      Time.zone.local(naive_date.year, naive_date.month, naive_date.day, naive_date.hour, naive_date.min, naive_date.sec)
    end

    localized_date.utc
  end

  def future_events
    return [] unless valid_calendar_data?
    all_future_events = @calendar_data["events"].select do |event|
      to_utc(event) >= Time.current.utc
    end

    all_future_events.sort_by { |event| to_utc(event) }
  end

  def format_date(date)
    Date.strptime(date, "%m/%d/%Y")
  end

  def valid_billing_data?
    return false if @billing_data.is_a?(Api::ErrorService::ApiError)
    @billing_data.is_a?(Hash) && @billing_data["price_cents"].present? && @billing_data["renewal_date"].present?
  end

  def valid_calendar_data?
    return false if @calendar_data.is_a?(Api::ErrorService::ApiError)
    @calendar_data.is_a?(Hash)
  end
end
