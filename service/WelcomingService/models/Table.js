const mongoose = require('mongoose');

const TableSchema = new mongoose.Schema({
    table_id: { type: Number, unique: true },  // ID tự động tăng, có thể thay bằng _id
    table_name: { type: String, required: true },
    status: { type: Boolean, require: true, default: false }
}, { collection: 'tables' });  // Đặt tên collection là `tables`

module.exports = mongoose.model('Table', TableSchema);
