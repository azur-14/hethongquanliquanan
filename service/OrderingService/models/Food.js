const mongoose = require('mongoose');

const FoodSchema = new mongoose.Schema({
    name: { type: String, required: true },
    status: { 
        type: String, 
        enum: ['active', 'inactive'], 
        default: 'active'
    },
    category: { type: mongoose.Schema.Types.ObjectId, ref: 'Category', required: true }, // Sử dụng ObjectId
    price: { type: Number, required: true},
    description: { type: String },
    image: { type: String },
}, { collection: 'foods' });

module.exports = mongoose.model('Food', FoodSchema);
