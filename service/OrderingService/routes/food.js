const express = require('express');
const Food = require('../models/Food');
const Category = require('../models/Category'); // Import model Category

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Foods
 *   description: API quản lý món ăn
 */

/**
 * @swagger
 * /api/foods:
 *   get:
 *     summary: Lấy danh sách món ăn (có thể lọc theo danh mục và tìm kiếm)
 *     tags: [Foods]
 *     parameters:
 *       - in: query
 *         name: categoryName
 *         schema:
 *           type: string
 *         description: Tên danh mục để lọc
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Tên món ăn cần tìm kiếm
 *     responses:
 *       200:
 *         description: Danh sách món ăn
 *       500:
 *         description: Lỗi server
 */
// Lấy danh sách món ăn, có thể lọc theo danh mục hoặc tìm kiếm (kitchenMenu, menu)
router.get('/', async (req, res) => {
    try {
        const { categoryName, search } = req.query;
        let filter = {};

        // Nếu có categoryName, tìm _id của category
        if (categoryName) {
            const category = await Category.findOne({ name: categoryName });
            if (category) {
                filter.category = category._id;
            } else {
                return res.json([]); // Không có danh mục phù hợp
            }
        }

        if (search) {
            filter.name = { $regex: search, $options: 'i' };
        }

        const foods = await Food.find(filter).populate('category');
        res.json(foods);
    } catch (error) {
        res.status(500).json({ message: "Lỗi server", error });
    }
});

/**
 * @swagger
 * /api/foods:
 *   post:
 *     summary: Thêm món ăn mới
 *     tags: [Foods]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               price:
 *                 type: number
 *               categoryName:
 *                 type: string
 *               status:
 *                 type: boolean
 *               description:
 *                 type: string
 *               image:
 *                 type: string
 *     responses:
 *       201:
 *         description: Món ăn đã được thêm thành công
 *       400:
 *         description: Dữ liệu không hợp lệ hoặc thiếu thông tin
 *       500:
 *         description: Lỗi server
 */
// Thêm món ăn mới (truyền categoryName thay vì categoryId)
router.post('/', async (req, res) => {
    try {
        const { name, price, categoryName, status, description, image } = req.body;

        if (!name || !price || !categoryName) {
            return res.status(400).json({ message: 'Thiếu thông tin bắt buộc' });
        }

        // Tìm categoryId dựa vào categoryName
        const category = await Category.findOne({ name: categoryName });

        if (!category) {
            return res.status(400).json({ message: 'Danh mục không tồn tại' });
        }

        const newFood = new Food({
            name,
            price,
            category: category._id, // Lưu ObjectId thay vì tên
            status,
            description,
            image
        });

        await newFood.save();
        res.status(201).json({ message: 'Món ăn đã được thêm!', food: newFood });
    } catch (error) {
        res.status(500).json({ message: "Lỗi server", error });
    }
});

/**
 * @swagger
 * /api/foods/{id}/status:
 *   put:
 *     summary: Cập nhật trạng thái của món ăn
 *     tags: [Foods]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của món ăn
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               status:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Cập nhật trạng thái thành công
 *       404:
 *         description: Không tìm thấy món ăn
 *       500:
 *         description: Lỗi server
 */
// PUT /api/foods/:id/status (kitchenMenu)
router.put('/:id/status', async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;
  
    try {
      const updated = await Food.findByIdAndUpdate(
        id,
        { status },
        { new: true }
      );
  
      if (!updated) {
        return res.status(404).json({ message: "Không tìm thấy món ăn" });
      }
  
      res.json({ message: "Cập nhật trạng thái thành công", food: updated });
    } catch (err) {
      res.status(500).json({ message: "Lỗi server", error: err });
    }
});

module.exports = router;
