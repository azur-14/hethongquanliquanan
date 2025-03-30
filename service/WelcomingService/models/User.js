const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    user_id: { type: Number, unique: true },  // ID tự động tăng, có thể thay thế bằng _id mặc định
    username: { type: String, required: false },
    password: { type: String, required: true },
    role: { 
        type: String, 
        enum: ['Quản lý', 'Nhân viên phục vụ', 'Nhân viên bếp'], // Chuyển tên vai trò sang tiếng Anh
        required: true
    }
}, { collection: 'users' });  // Đặt tên collection là `users`

module.exports = mongoose.model('User', UserSchema);
