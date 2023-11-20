# Welcome to the qe-automation repo!

## System Requirements

node/npm

## Getting Started

To set up this project to run locally, please follow these steps:

1. Clone [this repo](https://github.com/kel-o/sdet-takehome) using https
2. CD into this project
3. Run `npm install` to install all necessary packages & dependencies


## Running Tests

**Cypress Runner**

To launch the Cypress runner, from the project root directory, run `npx cypress open` - You can specify which browser to run tests on and run individual tests or the entire suite from the Cypress runner.

**CLI**

To run Cypress directly from the command line, run `npx cypress run` - `npx cypress run` accepts multiple options, some helpful commands are:

```
npx cypress run --spec 'path/to/file.js'    // run only one file
```

run `npx cypress run --help` for a full list of options

**Running tests against localhost**

In order to run tests against localhost, the following needs to be done:
1. In the Cypress repo, update cypress.json so that your baseUrl is `http://localhost:PORT`
  - `PORT` should be the port that full stack take home assignment is running on

**Structure**

To make this application DRY, I set up API classes in the following directory `cypress/support/framework/`, this way tests are more readable and code isn't repeated all over the place.



