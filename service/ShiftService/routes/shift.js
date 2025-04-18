const express = require('express');
const Shift = require('../models/Shift');

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Shifts
 *   description: API cho ca làm việc
 */

/**
 * @swagger
 * /api/shift:
 *   get:
 *     summary: Lấy tất cả ca làm việc
 *     tags: [Shifts]
 *     responses:
 *       200:
 *         description: Danh sách các ca làm việc
 */
// Lấy tất cả ca làm việc (thongke)
router.get('/', async (req, res) => {
    try {
      const shifts = await Shift.find();
      res.status(200).json(shifts);
    } catch (err) {
      res.status(500).json({ message: "Lỗi khi lấy danh sách ca", error: err.message });
    }
});

/**
 * @swagger
 * /api/shift/by-time:
 *   get:
 *     summary: Tìm ca làm việc theo thời gian cụ thể
 *     tags: [Shifts]
 *     parameters:
 *       - in: query
 *         name: time
 *         schema:
 *           type: string
 *         required: true
 *         description: Thời gian định dạng ISO string
 *     responses:
 *       200:
 *         description: Trả về tên ca làm việc phù hợp
 *       404:
 *         description: Không tìm thấy ca phù hợp
 */
// (thongke)
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

/**
 * @swagger
 * /api/shift/{id}:
 *   get:
 *     summary: Lấy thông tin ca theo shift_id
 *     tags: [Shifts]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Chi tiết ca làm việc
 *       404:
 *         description: Không tìm thấy ca làm việc
 */
// (order.js /completed)
router.get('/:id', async (req, res) => {
  try {
    const shiftId = parseInt(req.params.id);
    const shift = await Shift.findOne({ shift_id: shiftId });

    if (!shift) {
      return res.status(404).json({ message: 'Không tìm thấy ca làm việc' });
    }

    res.json(shift);
  } catch (err) {
    console.error("Lỗi khi lấy ca làm việc:", err);
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

/**
 * @swagger
 * /api/shift/generate-secret-codes:
 *   put:
 *     summary: Cập nhật mã bí mật ngẫu nhiên cho tất cả các ca
 *     tags: [Shifts]
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 *       500:
 *         description: Lỗi server
 */
// PUT: Cập nhật lại secretCode ngẫu nhiên cho toàn bộ ca (generalizeSecretCode)
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
      console.error("Lỗi khi cập nhật secretCode:", error);
      res.status(500).json({ error: "Lỗi server khi cập nhật secretCode" });
    }
});

/**
 * @swagger
 * /api/shift/secret-codes/current-shift:
 *   get:
 *     summary: Lấy mã bí mật của ca hiện tại
 *     tags: [Shifts]
 *     responses:
 *       200:
 *         description: Mã bí mật của ca hiện tại
 *       404:
 *         description: Không có ca nào đang hoạt động
 */
// GET /api/codes/current-shift (menu)
router.get('/secret-codes/current-shift', async (req, res) => {
  try {
    const now = new Date();
    now.setHours(now.getHours()); // VN time

    const allShifts = await Shift.find();

    for (const shift of allShifts) {
      const [fromHour, fromMin] = shift.from.split(':').map(Number);
      const [toHour, toMin] = shift.to.split(':').map(Number);

      const start = new Date(now);
      const end = new Date(now);
      start.setHours(fromHour, fromMin, 0, 0);
      end.setHours(toHour, toMin, 0, 0);

      if (end < start) end.setDate(end.getDate() + 1); // ca qua đêm

      if (now >= start && now <= end) {
        return res.json({ shiftId: shift.shift_id, shiftName: shift.name, secretCode: shift.secretCode });
      }
    }

    res.status(404).json({ message: 'Không có ca nào đang hoạt động' });
  } catch (error) {
    console.error("Lỗi khi lấy mã bí mật ca hiện tại:", error);
    res.status(500).json({ message: 'Lỗi server' });
  }
});

/**
 * @swagger
 * /api/shift/secret-codes/all:
 *   get:
 *     summary: Lấy tất cả mã bí mật của các ca
 *     tags: [Shifts]
 *     responses:
 *       200:
 *         description: Danh sách mã bí mật theo ca
 */
// GET: /api/codes/all (generalizeSecretCode)
router.get('/secret-codes/all', async (req, res) => {
  try {
    const shifts = await Shift.find().sort({ shift_id: 1 }); // sort by ca 1, 2, 3, 4
    const result = shifts.map(shift => ({
      shiftId: shift.shift_id,
      name: shift.name,
      secretCode: shift.secretCode,
    }));
    res.json({ shifts: result });
  } catch (err) {
    console.error("Lỗi khi lấy tất cả mã:", err);
    res.status(500).json({ message: "Lỗi server" });
  }
});

module.exports = router;
