const express = require('express');
const Food = require('../models/Food');
const Category = require('../models/Category'); // Import model Category

const router = express.Router();

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
