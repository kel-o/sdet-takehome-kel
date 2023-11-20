import EventsApi from "../../../support/framework/events_api"

context("GET /users", () => {
    it("gets a list of users", () => {
        EventsApi.getEvents(1).then((response) => {
            expect(response.status).to.eq(200)
            expect(JSON.stringify(response.body.events.length)).to.equal('4')
        })
    })
})












