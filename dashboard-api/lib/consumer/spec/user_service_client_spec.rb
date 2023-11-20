require 'faraday'
require 'pact/consumer/rspec'
require_relative 'pact_helper'

describe "UserServiceClient", :pact => true do
  it "can fetch user data"  do
    user_service.
      upon_receiving("a fetch user request").with({
      method: :get,
      path: '/users/1',
      headers: {'Accept' => 'application/json'}
    }).
      will_respond_with({
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        id: Pact.like("1"),
        first_name: Pact.like("Michael"),
        last_name: Pact.like("Scott")
      }
    })

    user_service_response = Faraday.get(user_service.mock_service_base_url + "/users/1", nil, {'Accept' => 'application/json'})
    # user_service_response = Api::UserService.get_user(user_service.mock_service_base_url + "/users/1" , nil, {'Accept' => 'application/json'})

   
    expect(user_service_response.status).to eql 200
    # expect(user_response.body).to eql({"id": 1, "first_name": "Michael", "last_name": "Scott"})
  end
end