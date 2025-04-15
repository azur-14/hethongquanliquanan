const express = require('express');
const connectShiftDB = require('./dtb');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');

const shiftRoutes = require('./routes/shift');

const app = express();
const PORT = 3002;

app.use(cors());
app.use(express.json());
app.use(bodyParser.json());

connectShiftDB(); // Kết nối MongoDB

// Routes
app.use('/api/shifts', shiftRoutes);

// Khởi chạy server
app.listen(PORT, () => {
    console.log(`ShiftService chạy trên cổng ${PORT}`);
});
