const express = require('express');
const router = express.Router();
const User = require('../models/User');

// Thêm người dùng mới
router.post('/', async (req, res) => {
    try {
        const { username, role } = req.body;

        // Tự động tăng user_id
        const maxUser = await User.findOne().sort({ user_id: -1 });
        const newUserId = maxUser ? maxUser.user_id + 1 : 1;

        const newUser = new User({
            user_id: newUserId,
            username,
            role
        });

        await newUser.save();
        res.status(201).json(newUser);
    } catch (err) {
        res.status(400).json({ error: 'Lỗi khi thêm người dùng mới' });
    }
});

// GET /api/users/:id - Lấy vai trò người dùng theo _id
router.get('/:id', async (req, res) => {
    try {
        const user = await User.findById(req.params.id).select('role');
        if (!user) {
            return res.status(404).json({ error: 'Không tìm thấy người dùng' });
        }
        res.json({ role: user.role });
    } catch (err) {
        res.status(500).json({ error: 'Lỗi khi lấy vai trò người dùng' });
    }
});

router.get('/password/admin', async (req, res) => {
    try {
      const admin = await User.findOne({ role: 'manager' });
  
      if (!admin) {
        return res.status(404).json({ message: 'Không tìm thấy tài khoản quản lý' });
      }
  
      res.json({
        password: admin.password
      });
  
    } catch (error) {
      console.error('Lỗi khi lấy mật khẩu admin:', error);
      res.status(500).json({ error: 'Lỗi server' });
    }
});

module.exports = router;
