import SubscriptionsApi from "../../../support/framework/subscriptions_api"

context("GET /subscriptions", () => {
    let body = JSON.stringify({ "user_id": 1, "renewal_date": "12/17/2023", "price_cents": 1500 })

    it("gets subscriptiond details for a user", () => {
        SubscriptionsApi.getSubscription(1).then((response) => {
            expect(response.status).to.eq(200)
            expect(JSON.stringify(response.body)).to.equal(body)
        })
    })
})

