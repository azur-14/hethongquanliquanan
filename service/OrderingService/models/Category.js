const mongoose = require('mongoose');

const CategorySchema = new mongoose.Schema({
    name: { type: String, required: true, unique: true }, // Tên danh mục
    description: { type: String }, // Mô tả danh mục
}, { collection: 'categories' });  // Đặt tên collection là `categories`

module.exports = mongoose.model('Category', CategorySchema);
