# API Documentation

## Summary Endpoint

    GET /summary/:user_id

## Description

Retrieves summary of user's profile information, past and upcoming meetings with meeting details, and billing details.

## Approach

 1. `Summary` will be populated with as much data as possible. If the billing service or calendar service is down, then errors are returned from that service and the respective fields are populated with an empty response.
 2. Errors list will always be present regardless or success or failure of call.
 3. The user service is viewed as central to the summary endpoint. Should it fail, then we "fail fast" and return an error.

## Parameters

|Parameter|  Data Type  | Required | Description						   |
| user_id     |     integer    |      Yes     | Unique Identifier of a User |


## Responses

**Success**

 - Status Code: 200
 - Response Body
	Note: No Errors from External Service
    ``{ "errors": [],
       "summary": {
           "user_name": "Full Name of User",
           "number_of_meetings_within_last_week": "Number of meetings held within last week", 
           "next_meeting": {
    	       "name": "Name of the Next Meeting",
    	       "date": "Date and Time of the Next Meeting (Localized with following time_zone)",
    	       "time_zone": "Time Zone of the Next Meeting",
    	       "duration": "Duration of the Next Meeting",
    	       "attendees": "Number of Attendees for the Next Meeting"
    	      },
    	     "subscription_cost": "Cost of the user's subscription",
    	     "days until subscription_renewal": "Number of days until subscription is renewed"
    	    }
    	 }``
With the exception of the user service, which is required, all services will return errors to the errors field. Failure of the billing and/or calendar service will still allow you to call the summary endpoint, but return nil for those particular fields as well as populate an error in the "errors" field.

- Billing Service Failure
`` {
      "errors":["Billing service error: <unsanitized error from the billing service>!"],
      "summary": {
        "user_name": "Michael Scott",
        "number_of_meetings_within_last_week": 4,
        "next_meeting": { "name": "Meeting in India", "date": "10/1/2023, 5:30:02 PM", "time_zone": "Asia/Kolkata", "duration": "30 minutes", "attendees": 2 },
        "subscription_cost": nil,
        "days_until_subscription_renewal": nil,
      },
    }``
    In this case, subscription cost and days until subscription renewal will be nil as the billing service is down
- Calendar Service Failure
`` {
      "errors" :["Calendar service error: <unsanitized error from the calendar service>!"],
      "summary": {
        "user_name": "Michael Scott",
        "number_of_meetings_within_last_week": 0,
        "next_meeting": nil,
        "subscription_cost": "$15.00",
        "days_until_subscription_renewal": "30 days left",
      },
    }``

Both Services Fail
``{
		{ "errors": ["Billing service error: <unsanitized error from the billing service>!",
"Calendar service error: <unsanitized error from the calendar service>!"],
      "summary": {
        "user_name": "Michael Scott",
        "number_of_meetings_within_last_week": 0,
        "next_meeting": nil,
        "subscription_cost": nill,
        "days_until_subscription_renewal": nil,
      },
``

**Errors**
 - Status Code: 422
User Service Failure
The user service is viewed as central to the other two services. Should it fail, the entire summary endpoint fails and no summary field is returned.

``{ "errors":  ["User service error: User not found"] }``


# Notes from the Delevoper
**Branching**
  - Base project is on ``main``
  - My submission is on ``code-day-submission``
**Services for External Api Calls**
*Responsiblity: Makes external api call, returns an error or data*
- ApiService handles the standard get calls to external services. Can be extended for other calls
- Error Service creates a standard error format usable by all external api call services
- Billing, calendar, and user services are specific to their endpoints
	- Anatomy of External Api Services:
		- Private method for endpoints. Method names follow this pattern: "#{endpoint name}_endpoint"
		- Flow:
			- Call to external api via ApiService is made
			- Strict response handling: as all endpoints expect a 200 status, we will create an error instance unless the status code is 200
			- JSON is parsed and returned from service


**Presenters**
*Responsibility: Parses and transforms data from external services used in their respective controllers*
 - Only one presenter exists at the moment: summary_presenter
	- User Service Transformation
		- Presents user's first name
	- Calendar Service Transformation
		- Sorts meetings, presents count of meetings within last week, and details of the next meeting
		- All times are converted to UTC for easy and accurate comparison, but these values are not returned. We return essentially what is given to us from other services. 
	- Billing Service Transformation
		- Presents easily consumable price in dollars and cents format
		- Presents number of days left (or days overdue) with regards to their subscription renewal date
	
**Controller**
 - Instantiates errors and a user id to be used throughout the controller
 - Only a user id is permitted to be passed in
 - All external services follow this pattern:
	 - Call service with user id
	 - Populate errors if there are any and return
	 - --OR--
	 - Return a successful response 
- Fail Fast: If the user endpoint has any errors, then we return early.

** Testing** 
Note: I'm more used to RSpec, but Minitest is great!
*How to run the tests!*
``docker exec -it <YOUR CONTAINER NAME> rails test``
E.G. 
``docker exec -it services-takehome-main-dashboard_api-1 rails test``

- External Services are mocked. Functionality not directly related to the thing being tested is likewise mocked.
- Presenters should really just be functions that transform already formatted data. This data will be parsed JSON from the external services
- Controller tests serve as a sort of End to End test for our api. The questions I attempt to answer in my controller test:
	- What happens if everything goes well?
	- What happens is the billing or calendar service is down? 
	- What if they're both down?
	- What if the user service is down?

## Opportunities

**Issues**
- Testing: 
	- The testing could be more exhaustive. Time constraints, coupled with relative unfamiliarity with MiniTest, led to a narrower testing focus.
	- There could be further consolidation of reused code (mocking time for instance)
- API Standardization: 
	- There's room for improvement in the standardization of the API responses and requests.
		- Service Architecture: 
			- In a more typical service-based architecture, services would lean more functional in nature
			- For instance, all services would have a .call() function. This would allow the error handling in the controller to be one function rather than 3. This could also be changed by renaming the existing methods simply to "get"
		- Could also create parent services for each external api service, but that could be added later
- Security & Logging: 
	- Logging issues are particularly nefarious and right now we take a lax approach to presenting logs to the front end. 
		- We should add an allowlist (ideally) or blocklist of logging messages we're ok with presenting. Otherwise, we return a generic error message

