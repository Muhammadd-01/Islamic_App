import https from 'https';

/**
 * Send a push notification using OneSignal REST API
 * @param {Object} options - Notification options
 * @param {string} options.title - Notification title
 * @param {string} options.message - Notification message
 * @param {Array<string>} [options.userIds] - Optional list of specific user IDs (external user IDs)
 * @param {Object} [options.data] - Optional metadata to include
 */
export const sendPushNotification = ({ title, message, userIds = [], data = {} }) => {
    const appId = process.env.ONESIGNAL_APP_ID;
    const restKey = process.env.ONESIGNAL_REST_API_KEY;

    if (!appId || !restKey) {
        console.error('OneSignal credentials missing in environment variables');
        return;
    }

    const body = {
        app_id: appId,
        headings: { en: title },
        contents: { en: message },
        data: data,
    };

    if (userIds && userIds.length > 0) {
        body.include_external_user_ids = userIds;
    } else {
        body.included_segments = ['All'];
    }

    const options = {
        hostname: 'onesignal.com',
        port: 443,
        path: '/api/v1/notifications',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': `Basic ${restKey}`,
        },
    };

    const req = https.request(options, (res) => {
        let output = '';
        res.on('data', (chunk) => {
            output += chunk;
        });
        res.on('end', () => {
            console.log('OneSignal API Response:', output);
        });
    });

    req.on('error', (e) => {
        console.error('OneSignal Request Error:', e);
    });

    req.write(JSON.stringify(body));
    req.end();
};
