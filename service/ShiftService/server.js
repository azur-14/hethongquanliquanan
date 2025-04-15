const express = require('express');
const connectShiftDB = require('./dtb');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');

const shiftRoutes = require('./routes/shift');

const app = express();
const PORT = 3002;

app.use(cors());
app.use(express.json());
app.use(bodyParser.json());

connectShiftDB(); // Kết nối MongoDB

// Swagger cấu hình
const swaggerOptions = {
    definition: {
      openapi: '3.0.0',
      info: {
        title: 'ShiftService API',
        version: '1.0.0',
        description: 'API quản lý ca',
      },
      servers: [
        {
          url: 'http://localhost:3002',
        },
      ],
    },
    apis: ['./routes/*.js'], // đường dẫn chứa annotation swagger
};
const swaggerDocs = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));

// Routes
app.use('/api/shifts', shiftRoutes);

// Khởi chạy server
app.listen(PORT, () => {
    console.log(`ShiftService chạy trên cổng ${PORT}`);
    console.log(`📚 Swagger docs tại http://localhost:${PORT}/api-docs`);
});
