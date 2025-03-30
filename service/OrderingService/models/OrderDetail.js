const mongoose = require('mongoose');

const OrderDetailSchema = new mongoose.Schema({
    orderId: { type: String, required: true, ref: 'Order' }, // Liên kết với DonHang
    foodId: { type: mongoose.Schema.Types.ObjectId, required: true, ref: 'Food' }, // Liên kết với MonAn
    quantity: { type: Number, required: true, min: 1 },
    price: { type: Number, required: true, min: 0 },
    ne: { type: String },
    status: { type: Boolean, require: true, default: false }
}, { collection: 'orderDetails' });

// Đảm bảo mỗi món trong đơn hàng chỉ có 1 bản ghi duy nhất
OrderDetailSchema.index({ orderId: 1, foodId: 1 }, { unique: true });

module.exports = mongoose.model('OrderDetail', OrderDetailSchema);
