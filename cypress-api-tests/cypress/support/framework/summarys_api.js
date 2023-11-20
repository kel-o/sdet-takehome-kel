class SummaryApi {
    getSummary(id) {
        const req = cy.request({
            method: "GET",
            url: `summary/${id}`,
            headers: {
                "Content-Type": "application/json",
            }
        });
        return req;
    }
}

export default new SummaryApi();
