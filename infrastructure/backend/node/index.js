// redis
// const redis = require('redis');
// const client = redis.createClient({
//     socket: {
//         host: 'j9a406.p.ssafy.io',
//         port: '56379'
//     },
//     username: '',
//     password: ''
// });
// client.on('connect', () => {
//     console.info('Redis connected!');
// });
// client.on('error', (err) => {
//     console.log('Redis Server Error', err)
// });
// client.connect().then();

// express
const express = require('express');
const app = express();
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// cors
const cors = require('cors');
app.use(cors());

// constrants
const PORT = process.env.PORT || 3010;

// remove header
// app.set('X-Powered-By', false);
// app.set('ETag', false);
// app.set('Date', false);

app.use((req, res, next) => {
    res.removeHeader('X-Powered-By');
    res.removeHeader('Access-Control-Allow-Origin');
    // res.removeHeader('Content-Type');
    // res.removeHeader('Content-Length');
    res.removeHeader('ETag');
    res.removeHeader('Date');
    // res.removeHeader('Connection');
    // res.removeHeader('Keep-Alive');
    next();
})

app.get('/api/exchange/orders', async (req, res) => {
    const {userNo, tokenNo, startDate, endDate} = req.body;
    console.log('BABO GET /api/exchange/orders ' + req.body);
    res.status(200).json({"orders": [ {
      "orderNo": 1,
      "userNo": 1,
      "tokenNo": 3,
      "tokenCode": "BABO",
      "price": 18000,
      "quantity": 13.54,
      "remain_quantity": 13.54,
      "orderTime": "1994-04-21",
      "sellOrBuy": 'S'
    }, {
      "orderNo": 2,
      "userNo": 1,
      "tokenNo": 3,
      "tokenCode": "BABO",
      "price": 18500,
      "quantity": 876.1,
      "remain_quantity": 876.1,
      "orderTime": "1994-04-21",
      "sellOrBuy": 'B'
    } ]});
});

app.get('/', (req, res) => {
    console.log('DEFAULT GET: ' + req.originalUrl);
    res.send('0');
});

app.use('*', (req, res) => {
    console.log('INVALID INPUT: ' + req.originalUrl);
    res.send('0');
});

/*
app.get('/default', async (req, res) => {
    console.log('DEFAULT /' + req.params.iot_command);
    res_value = await client.get('iot1_toy');
    console.log('initinal value: ' + res_value);
    res_value = await client.set('iot1_toy', '5');
    res_value = await client.get('iot1_toy');
    console.log('changed value: ' + res_value);
    res.send(res_value);
    console.log('END');
});
*/

app.listen(PORT, () => console.log('Listening on port', PORT));
