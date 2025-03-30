const mongoose = require('mongoose');

const CodeSchema = new mongoose.Schema({
    secretCode: { type: String, unique: true, required: true },
}, { collection: 'codes' });

module.exports = mongoose.model('Code', CodeSchema);
