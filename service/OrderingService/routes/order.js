const express = require('express');
const DonHang = require('../models/Order');
const OrderDetail = require('../models/OrderDetail');
const Food = require('../models/Food');
const { v4: uuidv4 } = require('uuid');
const axios = require('axios');

const router = express.Router();

// API lấy danh sách đơn hàng
router.get('/', async (req, res) => {
    try {
        const donhang = await DonHang.find();
        res.json(donhang);
    } catch (error) {
        res.status(500).json({ message: "Lỗi server", error });
    }
});

// API tạo đơn hàng (mỗi bàn chỉ có duy nhất 1 đơn hàng pending, nếu đã tồn tại thì chỉ thêm món vào OrderDetail)
router.post('/create', async (req, res) => {
  try {
    const { tableId, note, cart } = req.body;

    const existingOrder = await DonHang.findOne({
      tableId,
      status: 'pending'
    });

    // Nếu đơn hàng đã tồn tại → thêm món mới
    if (existingOrder) {
      const orderId = existingOrder.orderId;

      for (let item of cart) {
        const existingDetail = await OrderDetail.findOne({
          orderId,
          foodId: item.foodId
        });

        if (existingDetail) {
          await OrderDetail.updateOne(
            { orderId, foodId: item.foodId },
            {
              $set: {
                quantity: existingDetail.quantity + item.quantity,
                price: existingDetail.price + item.price * item.quantity
              }
            }
          );
        } else {
          await OrderDetail.create({
            orderId,
            foodId: item.foodId,
            quantity: item.quantity,
            price: item.price,
            ne: item.ne || "",
          });
        }
      }

      // Cập nhật lại tổng tiền
      const updatedDetails = await OrderDetail.find({ orderId });
      const newTotal = updatedDetails.reduce((sum, detail) => sum + detail.price, 0);

      // Gộp note cũ + note mới (nếu có)
      const oldNote = existingOrder.note || "";
      const combinedNote = (oldNote + "; " + (note || "")).trim();

      await DonHang.updateOne(
        { orderId },
        {
          $set: {
            total: newTotal,
            note: combinedNote
          }
        }
      );

      return res.status(200).json({ message: 'Order updated with new items', orderId });
    }

    // Nếu đơn hàng chưa tồn tại → tạo mới
    const orderId = uuidv4();
    const total = cart.reduce((sum, item) => sum + item.price * item.quantity, 0);

    const newOrder = new DonHang({
      orderId,
      tableId,
      note,
      total,
      status: 'pending',
    });

    await newOrder.save();

    const orderDetails = cart.map(item => ({
      orderId,
      foodId: item.foodId,
      quantity: item.quantity,
      price: item.price,
      ne: item.ne || "",
    }));

    await OrderDetail.insertMany(orderDetails);

    res.status(201).json({ message: 'Order created successfully', orderId });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to create or update order' });
  }
});

//Lấy danh sách đơn hàng có trạng thái pending và orderDetails của nó
router.get('/pending-with-details', async (req, res) => {
    try {
      const pendingOrders = await DonHang.find({ status: 'pending' });
  
      const result = await Promise.all(pendingOrders.map(async (order) => {
        const details = await OrderDetail.find({ orderId: order.orderId })
          .populate('foodId', 'name image'); // 👈 lấy tên + ảnh món ăn
  
        // Map lại để gộp tên vào object phẳng
        const formattedDetails = details.map(detail => ({
          ...detail._doc,
          name: detail.foodId?.name || '',
          image: detail.foodId?.image || '',
        }));
  
        return {
          ...order._doc,
          details: formattedDetails
        };
      }));
  
      res.json(result);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Lỗi khi lấy đơn hàng và chi tiết' });
    }
});
  
  
// GET: Đơn hàng theo tableId và trạng thái hoặc orderId
router.get('/bill/:tableId', async (req, res) => {
  try {
    const { tableId } = req.params;
    const { status = 'pending', orderId } = req.query;

    let order;

    if (orderId) {
      // 🔍 Ưu tiên tìm theo orderId nếu được truyền
      order = await DonHang.findOne({
        tableId: parseInt(tableId),
        orderId: orderId,
      });
    } else {
      // 🔍 Ngược lại, tìm theo status
      order = await DonHang.findOne({
        tableId: parseInt(tableId),
        status: status,
      });
    }

    if (!order) {
      return res.status(404).json({ message: 'Không tìm thấy đơn hàng' });
    }

    // Lấy chi tiết đơn hàng
    const orderDetails = await OrderDetail.find({ orderId: order.orderId });

    // 🍽 Lấy thông tin món ăn
    const detailsWithFood = await Promise.all(
      orderDetails.map(async (detail) => {
        const food = await Food.findById(detail.foodId);
        return {
          foodId: detail.foodId,
          name: food?.name || 'Không rõ',
          image: food?.image || '',
          quantity: detail.quantity,
          price: detail.price,
          status: detail.status,
        };
      })
    );

    // 📤 Trả về đơn hàng đầy đủ
    res.json({
      orderId: order.orderId,
      tableId: order.tableId,
      status: order.status,
      note: order.note || '',
      total: order.total,
      details: detailsWithFood,
    });
  } catch (error) {
    console.error('🔥 Lỗi khi lấy đơn hàng theo tableId:', error);
    res.status(500).json({ error: 'Lỗi server' });
  }
});

// GET: Lấy danh sách các đơn hàng có trạng thái completed
router.get('/completed', async (req, res) => {
  try {
    const { fromDate, toDate, shiftId } = req.query;

    if (!fromDate || !toDate) {
      return res.status(400).json({ message: 'Thiếu fromDate hoặc toDate' });
    }

    const from = new Date(fromDate);
    const to = new Date(toDate);
    to.setHours(23, 59, 59, 999);

    // 1. Lọc theo thời gian
    let filter = {
      status: 'completed',
      timeEnd: { $gte: from, $lte: to }
    };

    let orders = await DonHang.find(filter).lean();

    // 2. Nếu có shiftId, gọi sang shift service
    if (shiftId) {
      const shiftApi = `http://localhost:3002/api/shifts/${shiftId}`;
      const shiftRes = await axios.get(shiftApi);
      const shift = shiftRes.data;

      const [fromHour, fromMin] = shift.from.split(':').map(Number);
      const [toHour, toMin] = shift.to.split(':').map(Number);

      // Giới hạn chỉ lấy đơn hàng của ngày fromDate (giờ VN)
      orders = orders.filter(order => {
        const utcTime = new Date(order.timeEnd);
        const vnTime = new Date(utcTime.getTime() - 7 * 60 * 60 * 1000); // ⏰ +7h

        // Chỉ xét đơn hàng trong đúng ngày fromDate (theo giờ VN)
        const sameDate =
          vnTime.getFullYear() === from.getFullYear() &&
          vnTime.getMonth() === from.getMonth() &&
          vnTime.getDate() === from.getDate();

        if (!sameDate) return false;

        const fromTime = new Date(vnTime);
        const toTime = new Date(vnTime);
        fromTime.setHours(fromHour, fromMin, 0, 0);
        toTime.setHours(toHour, toMin, 0, 0);
        if (toTime < fromTime) toTime.setDate(toTime.getDate() + 1); // xử lý ca qua ngày

        const inShift = vnTime >= fromTime && vnTime <= toTime;

        return inShift;
      });
    }

    res.json(orders);
  } catch (error) {
    console.error("❌ Lỗi khi lọc hóa đơn:", error);
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
});
  
// Cập nhật trạng thái đơn hàng thành completed
router.put('/:orderId/status', async (req, res) => {
    try {
      const { orderId } = req.params;
  
      const updatedOrder = await DonHang.findOneAndUpdate(
        { orderId },
        {
            status: 'completed',
            timeEnd: new Date()
        },
        { new: true }
      );
  
      if (!updatedOrder) {
        return res.status(404).json({ message: 'Không tìm thấy đơn hàng.' });
      }
  
      res.json({ message: 'Cập nhật trạng thái thành công.', order: updatedOrder });
    } catch (error) {
      console.error("❌ Lỗi khi cập nhật trạng thái đơn hàng:", error);
      res.status(500).json({ error: 'Lỗi server khi cập nhật trạng thái.' });
    }
});
  
module.exports = router;
