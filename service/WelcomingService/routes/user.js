const express = require('express');
const router = express.Router();
const User = require('../models/User');

// (welcome)
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
