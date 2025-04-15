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

router.get('/:id', async (req, res) => {
  try {
    const shiftId = parseInt(req.params.id);
    const shift = await Shift.findOne({ shift_id: shiftId });

    if (!shift) {
      return res.status(404).json({ message: 'Không tìm thấy ca làm việc' });
    }

    res.json(shift);
  } catch (err) {
    console.error("❌ Lỗi khi lấy ca làm việc:", err);
    res.status(500).json({ message: 'Lỗi server', error: err.message });
  }
});

// Hàm tạo mã bí mật ngẫu nhiên (6 ký tự)
function generateSecretCode(length = 6) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < length; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
}
  
  // PUT: Cập nhật lại secretCode ngẫu nhiên cho toàn bộ ca
router.put('/generate-secret-codes', async (req, res) => {
    try {
      const shifts = await Shift.find();
  
      const updatedShifts = await Promise.all(
        shifts.map(async (shift) => {
          const newCode = generateSecretCode();
          shift.secretCode = newCode; // luôn cập nhật lại
          await shift.save();
          return {
            shift_id: shift.shift_id,
            name: shift.name,
            newSecretCode: newCode
          };
        })
      );
      console.log(updatedShifts);
  
      res.json({
        message: 'Đã cập nhật lại secretCode cho tất cả các ca',
        shifts: updatedShifts
      });
    } catch (error) {
      console.error("❌ Lỗi khi cập nhật secretCode:", error);
      res.status(500).json({ error: "Lỗi server khi cập nhật secretCode" });
    }
});

// GET: Lấy tất cả các ca và secretCode
router.get('/secret-codes', async (req, res) => {
    try {
      const shifts = await Shift.find().select('shift_id name secretCode');
      res.json({ shifts });
    } catch (err) {
      res.status(500).json({ message: 'Lỗi server', error: err.message });
    }
});  

module.exports = router;
