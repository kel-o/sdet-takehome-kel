class UserApi {
    getUser(id) {
        const req = cy.request({
            method: "GET",
            url: `users/${id}`,
            headers: {
                "Content-Type": "application/json",
            }
        });
        return req;
    }
}

export default new UserApi();
