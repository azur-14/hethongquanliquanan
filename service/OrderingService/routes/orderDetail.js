const express = require('express');
const OrderDetail = require('../models/OrderDetail');
const DonHang = require('../models/Order');

const router = express.Router();

// Lấy tất cả chi tiết đơn hàng kèm tên món ăn
router.get('/', async (req, res) => {
    try {
        const details = await OrderDetail.find().populate('foodId', 'name');
        res.json(details);
    } catch (err) {
        res.status(500).json({ error: 'Lỗi khi lấy danh sách chi tiết đơn hàng' });
    }
});

// GET: Lấy danh sách OrderDetail theo tableId (chỉ đơn hàng pending) (orderPage)
router.get('/table/:tableId', async (req, res) => {
    try {
      const tableId = req.params.tableId;
  
      // Tìm đơn hàng đang pending theo tableId
      const order = await DonHang.findOne({ tableId, status: 'pending' });
  
      if (!order) {
        return res.json([]); // Không có đơn pending => trả mảng rỗng
      }
  
      const details = await OrderDetail.find({ orderId: order.orderId })
        .populate('foodId', 'name image');
  
      // Map lại dữ liệu gọn hơn
      const result = details.map(item => ({
        name: item.foodId.name,
        image: item.foodId.image || 'assets/food.jpg',
        quantity: item.quantity,
        price: item.price,
        status: item.status,
      }));
  
      res.json(result);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Lỗi server khi lấy chi tiết đơn hàng theo bàn' });
    }
});
  
//Cập nhật trạng thái ctdh (kicthenOrder)
router.put('/:id/status', async (req, res) => {
    const { status } = req.body;
    try {
      await OrderDetail.findByIdAndUpdate(req.params.id, { status });
      res.json({ message: 'Cập nhật trạng thái thành công' });
    } catch (error) {
      res.status(500).json({ error: 'Lỗi cập nhật trạng thái' });
    }
});
  
module.exports = router;
