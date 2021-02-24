'use strict';
// NOTE: this is not a javascript file! The following interpolation is made by
// terraform. This happens so that we can have different users on different
// environments, we do not use environment variables as Lambda@Edge does not
// support them.
const validStrings = "${BASIC_AUTH_ENTRIES}"
    .split(',')
    .map(e => ('Basic ' + Buffer.from(e).toString('base64')));

const getFirstHeader = (headers, key) => (((headers[key] || [])[0] || {}).value);

exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;
    const headers = request.headers;

    console.log(JSON.stringify(request, null, 2));

    const authHeader = getFirstHeader(headers, 'authorization');
    if (typeof headers.authorization === 'undefined' || 
        !validStrings.includes(authHeader)) {

        return callback(null, {
            status: '401',
            statusDescription: 'Unauthorized',
            body: 'Unauthorized',
            headers: {
                'www-authenticate': [{key: 'WWW-Authenticate', value:'Basic'}],
            }
        });
    }

    callback(null, request);
};
