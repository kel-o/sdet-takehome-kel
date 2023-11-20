# SDET Take Home Exercise

Welcome to the Calendly Take Home assignment! This exercise will focus on testing a Service Oriented Architecture (SOA).

# Getting Started

Clone a copy of this repo locally and run the following command from the project root:
```sh
docker compose up --build
```

Access the "Summary Dashboard" by visiting this URL in a browser: 
 - [http://localhost:8000/summary/1](http://localhost:8000/summary/1)

# Objectives

- Write automated tests for the critical API endpoints of each microservice (Billing, Calendar, User).
- Implement contract tests validating the requests and responses against their defined contracts (Swagger/OpenAPI specifications).

# Services

[Billing Service](billing-service/README.md)

[Calendar Service](calendar-service/README.md)

[User Service](user-service/README.md)

[Dashboard API](dashboard-api/README.md)

# Final Submission

Create a PR in a forked repository and fill out the description with an overview of your changes. Email a link to the PR to your recruiter.
