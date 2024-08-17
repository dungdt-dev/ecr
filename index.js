exports.handler = async (event) => {
    const response = {
        statusCode: 200,
        body: JSON.stringify('Hello from AWS CLOUD DEMOS!!! Test push ecr 1'),
    };
    return response;
};