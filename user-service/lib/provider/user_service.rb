class UserService
    def call env
      status = 200
      headers = {'Content-Type' => 'application/json'}
      body = {
        "id": "1",
        "first_name": "Michael",
        "last_name": "Scott"
      }.to_json
      [status, headers, [body]]
    end
  end