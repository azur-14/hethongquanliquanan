const express = require('express');
const Shift = require('../models/Shift');

const router = express.Router();

// Lấy tất cả ca làm việc
router.get('/', async (req, res) => {
    try {
      const shifts = await Shift.find();
      res.status(200).json(shifts);
    } catch (err) {
      res.status(500).json({ message: "Lỗi khi lấy danh sách ca", error: err.message });
    }
});

router.get('/by-time', async (req, res) => {
    try {
      const timeParam = req.query.time;
      if (!timeParam) return res.status(400).json({ message: 'Thiếu tham số thời gian' });
  
      const inputTime = new Date(timeParam);
      inputTime.setHours(inputTime.getHours() - 7); // ➕ Chuyển sang giờ VN
  
      const shifts = await Shift.find();
  
      for (const shift of shifts) {
        const [fromHour, fromMin] = shift.from.split(':').map(Number);
        const [toHour, toMin] = shift.to.split(':').map(Number);
  
        const fromTime = new Date(inputTime);
        fromTime.setHours(fromHour, fromMin, 0, 0);
  
        const toTime = new Date(inputTime);
        toTime.setHours(toHour, toMin, 0, 0);
        if (toTime < fromTime) toTime.setDate(toTime.getDate() + 1); // Xử lý ca qua ngày
  
        if (inputTime >= fromTime && inputTime <= toTime) {
          return res.json({ shiftName: shift.name });
        }
      }
  
      res.status(404).json({ message: 'Không tìm thấy ca phù hợp' });
    } catch (err) {
      res.status(500).json({ message: 'Lỗi server', error: err.message });
    }
});

module.exports = router;
