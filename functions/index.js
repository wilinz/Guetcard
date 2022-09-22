const { default: axios } = require('axios');
const functions = require('firebase-functions');
const http = require('http');
const https = require('https');

exports.proxy = functions.https.onRequest(async (req, res) => {
    if ( // req.headers.origin === 'https://guet_card.web.app' || req.headers.origin?.includes('127.0.0.1') &&
        req.query.url != null &&
        req.query.url.startsWith('http')) {
        // TODO: 似乎在 redirect 的情况下会出问题
        const url = decodeURIComponent(req.query.url);
        axios.request({
            method: req.method,
            url: url,
            headers: req.headers,
            data: req.body,
        }).then((result) => {
            res.send(JSON.stringify(result.data));
            // res.send('hello');
        }).catch((e) => {
            console.error(e);
            res.end();
        });
    }
});
