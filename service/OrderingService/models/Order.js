const mongoose = require('mongoose');

const OrderSchema = new mongoose.Schema({
    orderId: { type: String, required: true, unique: true }, 
    tableId: { type: Number, required: true },  // Liên kết với `ban` từ WelcomingService
    timeCreated: { type: Date, default: Date.now },
    timeEnd: { type: Date, default: "" },
    status: { 
        type: String, 
        enum: ['pending', 'completed'], 
        required: true 
    },
    note: { type: String },
    total: { type: Number, required: true, min: 0 }
}, { collection: 'orders' });

module.exports = mongoose.model('Order', OrderSchema);
