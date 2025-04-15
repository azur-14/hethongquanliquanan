const express = require('express');
const DonHang = require('../models/Order');
const OrderDetail = require('../models/OrderDetail');
const Food = require('../models/Food');
const { v4: uuidv4 } = require('uuid');
const axios = require('axios');

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Orders
 *   description: API quản lý đơn hàng
 */

/**
 * @swagger
 * /api/orders:
 *   get:
 *     summary: Lấy danh sách đơn hàng
 *     tags: [Orders]
 *     responses:
 *       200:
 *         description: Danh sách đơn hàng
 *       500:
 *         description: Lỗi server
 */
// API lấy danh sách đơn hàng
router.get('/', async (req, res) => {
    try {
        const donhang = await DonHang.find();
        res.json(donhang);
    } catch (error) {
        res.status(500).json({ message: "Lỗi server", error });
    }
});

/**
 * @swagger
 * /api/orders/create:
 *   post:
 *     summary: Tạo đơn hàng hoặc cập nhật nếu đã tồn tại
 *     tags: [Orders]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               tableId:
 *                 type: integer
 *               note:
 *                 type: string
 *               cart:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     foodId:
 *                       type: string
 *                     quantity:
 *                       type: number
 *                     price:
 *                       type: number
 *                     ne:
 *                       type: string
 *     responses:
 *       201:
 *         description: Đơn hàng đã được tạo hoặc cập nhật
 *       500:
 *         description: Lỗi khi tạo hoặc cập nhật đơn hàng
 */
// API tạo đơn hàng (mỗi bàn chỉ có duy nhất 1 đơn hàng pending, nếu đã tồn tại thì chỉ thêm món vào OrderDetail) (menu)
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

/**
 * @swagger
 * /api/orders/pending-with-details:
 *   get:
 *     summary: Lấy danh sách đơn hàng đang chờ và chi tiết của chúng
 *     tags: [Orders]
 *     responses:
 *       200:
 *         description: Danh sách đơn hàng đang chờ
 *       500:
 *         description: Lỗi server
 */
//Lấy danh sách đơn hàng có trạng thái pending và orderDetails của nó (kitchenOrder)
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
  
/**
 * @swagger
 * /api/orders/bill/{tableId}:
 *   get:
 *     summary: Lấy đơn hàng theo tableId hoặc orderId
 *     tags: [Orders]
 *     parameters:
 *       - in: path
 *         name: tableId
 *         schema:
 *           type: string
 *         required: true
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *         description: Trạng thái đơn hàng (pending, completed,...)
 *       - in: query
 *         name: orderId
 *         schema:
 *           type: string
 *         description: Mã đơn hàng cụ thể
 *     responses:
 *       200:
 *         description: Chi tiết đơn hàng
 *       404:
 *         description: Không tìm thấy đơn hàng
 */
// GET: Đơn hàng theo tableId và trạng thái hoặc orderId (bill)
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
    console.error('Lỗi khi lấy đơn hàng theo tableId:', error);
    res.status(500).json({ error: 'Lỗi server' });
  }
});

/**
 * @swagger
 * /api/orders/completed:
 *   get:
 *     summary: Lọc danh sách đơn hàng hoàn tất theo thời gian và ca
 *     tags: [Orders]
 *     parameters:
 *       - in: query
 *         name: fromDate
 *         schema:
 *           type: string
 *         required: true
 *       - in: query
 *         name: toDate
 *         schema:
 *           type: string
 *         required: true
 *       - in: query
 *         name: shiftId
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Danh sách đơn hàng hoàn tất theo điều kiện lọc
 *       400:
 *         description: Thiếu thông tin ngày
 *       500:
 *         description: Lỗi server
 */
// GET: Lấy danh sách các đơn hàng có trạng thái completed (thongke)
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
    console.error("Lỗi khi lọc hóa đơn:", error);
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
});
  
/**
 * @swagger
 * /api/orders/{orderId}/status:
 *   put:
 *     summary: Cập nhật trạng thái đơn hàng thành completed
 *     tags: [Orders]
 *     parameters:
 *       - in: path
 *         name: orderId
 *         schema:
 *           type: string
 *         required: true
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 *       404:
 *         description: Không tìm thấy đơn hàng
 *       500:
 *         description: Lỗi server khi cập nhật trạng thái
 */
// Cập nhật trạng thái đơn hàng thành completed (bill)
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
      console.error("Lỗi khi cập nhật trạng thái đơn hàng:", error);
      res.status(500).json({ error: 'Lỗi server khi cập nhật trạng thái.' });
    }
});
  
module.exports = router;
