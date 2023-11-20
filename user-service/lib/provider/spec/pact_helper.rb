require_relative '../user_service.rb'

Pact.configuration.reports_dir = "./provider/reports"

Pact.service_provider "UserService" do
  app { UserService.new }
  app_version '1.2.3'
  publish_verification_results !!ENV['PUBLISH_VERIFICATIONS_RESULTS']

  honours_pact_with 'DashboardApi' do
    pact_uri '/Users/kelokekpe/src/services-takehome/dashboard-api/lib/consumer/spec/pacts/dashboardapi-userservice.json'
  end
end