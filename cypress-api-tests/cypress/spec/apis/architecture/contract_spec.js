import SummaryApi from "../../../support/framework/summarys_api";

context("GET /summary", () => {

    it("determines if any services are broken", () => {
        SummaryApi.getSummary(1).then((response) => {
            expect(response.status).to.eq(200)
            expect(response.body.errors.length).to.eq(0)
        })
    })
})

// the /summary endpoint contains an errors field
// when the errors field not empty, that means a service is not responding or is responding incorrectly.