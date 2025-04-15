const mongoose = require('mongoose');

const ShiftSchema = new mongoose.Schema({
    shift_id: { type: Number, unique: true }, 
    name: { type: String, required: true },
    from: { type: String, required: true },
    to: { type: String, required: true },
    time: { type: Date, default: Date.now },
    secretCode: { type: String, required: true },
}, { collection: 'shifts' });

module.exports = mongoose.model('Shift', ShiftSchema);
