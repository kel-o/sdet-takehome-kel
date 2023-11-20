# How to run submission

# Starting Services
To start the services that these tests will run against, peform the following actions

_From root directory, run the following command:_
```
$ docker compose up --build
```

Access the "Summary Dashboard" by visiting this URL in a browser: 
 - [http://localhost:8000/summary/1](http://localhost:8000/summary/1)

   
# Running Cypress
To run api tests against these services, perform the following actions 

**Run cypress api tests**
_From cypress directory_

install packages and dependencies
```
$ npm install
```
run tests
```
$ npx cypress run
```

# Running Contract Tests
To setup pacts, start local pact broker and run contract tests between two services, perform the following actions

**As the Consumer**

The dashboard-api by definition is the consumer of our contract tests. It fetches user data from the user-service and displays it on the /summarys page.

To create a pact, run the following command:

_From the dashboard-api directory_
```
$ bundle exec rake consumer_spec
```
This will create the pact, which are the contract specifications between dashboard-api consumer and the user-service provider. (ie. When I send a request with foo in the body then I shold expect a response with bar in the body)

_From the pact_broker directory_
```
$ bundle exec rackup
```
This will start the rack server which hosts the pact broker , the pact acts as an intermediary between the two services and is the glue that makes the contract test come together. It is the shared contract created by running the consumer spec, and honored by the user-service provider.

The rack server runs on localhost:9292


**As the Provider**

The user-service application feeds the dashboard-api data about a user when requested. This means the user-service is the provider.

_To run an e2e test, run the following command:_
```
$ bundle exec rake pact:verify:dashboard-api_and_user-service_contract_using_local_broker
```
This will generate a pact as the consumer if one does not already exist and it will run the pact as the provider.



# Contract Test Locations

**consumer:**
[Dashboard API Tests](dashboard-api/lib)


**provider:**
[User Service Tests](user-service/lib)


