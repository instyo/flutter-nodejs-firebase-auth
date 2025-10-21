const express = require('express');
const cors = require("cors");
const cookieParser = require('cookie-parser');

require("dotenv").config();

// Initialize Firebase before importing routes
require('./config/firebase');

const router = require("./route");

const SERVER_PORT = process.env.SERVER_PORT || 8080;
const SERVER_HOST = process.env.SERVER_HOST || '0.0.0.0';

const app = express();

app.use(cors({
    origin: ['http://localhost:3614'],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    credentials: true
}));


app.use(express.json());
app.use(express.urlencoded({ extended: true })); // This is crucial for Apple callback
app.use(cookieParser());


app.use(router);


app.get('/', (req, res) => {
    res.send('Hello World');
});


app.listen(SERVER_PORT, SERVER_HOST, () => {
    console.log(`Listening on ${SERVER_HOST}:${SERVER_PORT}`);
});

module.exports = app;