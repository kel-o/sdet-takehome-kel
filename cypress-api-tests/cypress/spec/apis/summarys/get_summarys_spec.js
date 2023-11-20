import SummaryApi from "../../../support/framework/summarys_api";

context("GET /subscriptions", () => {

    let name = "Michael Scott"

    it("gets subscriptiond details for a user", () => {
        SummaryApi.getSummary(1).then((response) => {
            expect(response.status).to.eq(200)
            expect(response.body.summary.user_name).to.eq(name)
        })
    })
})

