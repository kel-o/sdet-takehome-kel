[< Back to Assignment](../README.md)


## How to Contract Test Provider Locally
The `user-service` application feeds the `dashboard-api` data about a user when requested. This means the `user-service` is the provider and the `dashboard-api` service is the consumer.

To run an e2e test, run the following command:
```
$ bundle exec rake pact:verify:dashboard-api_and_user-service_contract_using_local_broker
```

This will generate a pact as the consumer if one does not already exist and it will run the pact as the provider.


## Users (Ruby on Rails)
This service stores information about a user.

### Users Endpoint

**Host Endpoint:** `http://localhost:8000/users/<id>`

**Docker Network Endpoint:** `http://user-service:8000/users/<id>`

**Method:** GET

**Description:** Retrieve a specific user record, also used as a proxy for authorization if a user record can't be found.

### Example Responses

**Success**
```json
{
    "id": <int>,
    "first_name": <string>,
    "last_name": <string>,
}
```

**Error**
```json
{
    "message": <error message>
}
```

### Response Codes

| Status Code | Description      |
| ----------- | ---------------- |
| 200         | OK               |
| 404         | Record not Found |
