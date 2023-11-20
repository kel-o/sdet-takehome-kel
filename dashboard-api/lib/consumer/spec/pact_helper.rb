require 'pact/consumer/rspec'

Pact.configuration.pact_dir = File.dirname(__FILE__) + "/pacts"

Pact.service_consumer "DashboardApi" do
  has_pact_with "UserService" do
    mock_service :user_service do
      pact_specification_version "2"
      port 4638
    end
  end
end