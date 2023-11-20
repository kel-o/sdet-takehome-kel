class EventsApi {
    getEvents(id) {
        const req = cy.request({
            method: "GET",
            url: `events?user_id=${id}`,
            headers: {
                "Content-Type": "application/json",
            }
        });
        return req;
    }
}

export default new EventsApi();
