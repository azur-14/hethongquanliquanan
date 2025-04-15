const express = require('express');
const connectDB = require('./dtb');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');

const tableRoutes = require('./routes/table');
const userRoutes = require('./routes/user');

const app = express();
const PORT = 3003;

app.use(cors());
app.use(express.json());
app.use(bodyParser.json());

// Kết nối MongoDB
connectDB();

// Swagger cấu hình
const swaggerOptions = {
    definition: {
      openapi: '3.0.0',
      info: {
        title: 'WelcomingService API',
        version: '1.0.0',
        description: 'API quản lý người dùng và bàn',
      },
      servers: [
        {
          url: 'http://localhost:3003',
        },
      ],
    },
    apis: ['./routes/*.js'], // đường dẫn chứa annotation swagger
};
  
const swaggerDocs = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));
  

// Routes
app.use('/api/table', tableRoutes);
app.use('/api/users', userRoutes);

// Khởi chạy server
app.listen(PORT, () => {
    console.log(`WelcomingService chạy trên cổng ${PORT}`);
    console.log(`📚 Swagger docs tại http://localhost:${PORT}/api-docs`);
});
