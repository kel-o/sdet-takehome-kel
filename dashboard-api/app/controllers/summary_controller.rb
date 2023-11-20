require "uri"
require "net/http"

class SummaryController < ApplicationController
  def show
    @user_id = user_params[:user_id]

    @errors = []

    user_service_response = handle_user_service_response

    return render json: { errors: @errors }, status: 422 if @errors.any?
    billing_service_response = handle_billing_service_response
    calendar_service_response = handle_calendar_service_response

    render json: {
      errors: @errors,
      summary: SummaryPresenter.new(user_service_response, billing_service_response, calendar_service_response).present,
    }
  end

  private

  def handle_user_service_response
    user_service_response = Api::UserService.new(@user_id).get_user
    return user_service_response unless user_service_response.is_a?(Api::ErrorService::ApiError)
    @errors << "User service error: #{user_service_response.message}" if user_service_response.is_a?(Api::ErrorService::ApiError)
  end

  def handle_calendar_service_response
    calendar_service_response = Api::CalendarService.new(@user_id).get_events
    return calendar_service_response unless calendar_service_response.is_a?(Api::ErrorService::ApiError)
    @errors << "Calendar service error: #{calendar_service_response.message}"
  end

  def handle_billing_service_response
    billing_service_response = Api::BillingService.new(@user_id).get_subscription
    return billing_service_response unless billing_service_response.is_a?(Api::ErrorService::ApiError)
    @errors << "Billing service error: #{billing_service_response.message}" if billing_service_response.is_a?(Api::ErrorService::ApiError)
  end

  def user_params
    params.permit(:user_id)
  end
end
