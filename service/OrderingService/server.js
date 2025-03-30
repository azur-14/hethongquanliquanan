const express = require('express');
const connectDB = require('./dtb');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');

const foodRoutes = require('./routes/food');
const donHangRoutes = require('./routes/order');
const categoryRoutes = require('./routes/category');
const orderDetailRoutes = require('./routes/orderDetail');

const app = express();
const PORT = 3001;

app.use(cors());
app.use(express.json());
app.use(bodyParser.json());

// Kết nối MongoDB
connectDB();

// Routes
app.use('/api/orders', donHangRoutes);
app.use('/api/foods', foodRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/orderdetails', orderDetailRoutes);

// Khởi chạy server
app.listen(PORT, () => {
    console.log(`🚀 OrderingService chạy trên cổng ${PORT}`);
});
