const express = require('express');
const Code = require('../models/Code');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');

// Tạo mới secretCode (xóa mã cũ trước)
router.post('/create', async (req, res) => {
  try {
    // Xoá tất cả mã cũ
    await Code.deleteMany({});

    // Tạo mã mới ngẫu nhiên
    const secretCode = uuidv4().split('-')[0].toUpperCase(); // Ví dụ: 'A1B2C3D4'

    const newCode = new Code({ secretCode });
    await newCode.save();

    res.status(201).json({ message: 'Tạo mã bí mật mới thành công', secretCode });
  } catch (error) {
    console.error('Lỗi khi tạo mã bí mật:', error);
    res.status(500).json({ error: 'Lỗi server khi tạo mã bí mật' });
  }
});

// API lấy mã bí mật hiện tại
router.get('/', async (req, res) => {
    try {
      const latestCode = await Code.findOne().sort({ _id: -1 }); // Lấy mã mới nhất
  
      if (!latestCode) {
        return res.status(404).json({ message: 'Chưa có mã bí mật nào' });
      }
  
      res.json({ secretCode: latestCode.secretCode });
    } catch (error) {
      console.error('Lỗi khi lấy mã bí mật:', error);
      res.status(500).json({ error: 'Lỗi server khi lấy mã bí mật' });
    }
});

module.exports = router;
