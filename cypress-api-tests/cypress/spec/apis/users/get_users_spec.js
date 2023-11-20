import UserApi from "../../../support/framework/users_api"

context("GET /users/:id", () => {

    let first_name = "Michael"
    let last_name = "Scott"

    it("gets user details", () => {
        UserApi.getUser(1).then((response) => {
            expect(response.status).to.eq(200)
            expect(response.body.first_name).to.eq(first_name)
            expect(response.body.last_name).to.eq(last_name)
        })
    })
})

