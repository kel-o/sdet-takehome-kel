class SubscriptionsApi {
    getSubscription(id) {
        const req = cy.request({
            method: "GET",
            url: `subscriptions?user_id=${id}`,
            headers: {
                "Content-Type": "application/json",
            }
        });
        return req;
    }
}

export default new SubscriptionsApi();
