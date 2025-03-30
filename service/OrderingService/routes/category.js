const express = require('express');
const Category = require('../models/Category');

const router = express.Router();

// 📌 API Lấy danh sách danh mục
router.get('/', async (req, res) => {
    try {
        const categories = await Category.find();
        res.json(categories);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
});

// 📌 API Tạo danh mục mới
router.post('/create', async (req, res) => {
    try {
        const { name, description } = req.body;

        if (!name) {
            return res.status(400).json({ message: 'Tên danh mục là bắt buộc' });
        }

        // Kiểm tra xem danh mục đã tồn tại chưa
        const existingCategory = await Category.findOne({ name });
        if (existingCategory) {
            return res.status(400).json({ message: 'Danh mục đã tồn tại' });
        }

        const newCategory = new Category({ name, description });
        await newCategory.save();
        res.status(201).json({ message: 'Danh mục được tạo thành công!', category: newCategory });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
});

router.put('/:id', async (req, res) => {
    try {
        const { name, description } = req.body;
        const updatedCategory = await Category.findByIdAndUpdate(
            req.params.id,
            { name, description },
            { new: true }
        );
        if (!updatedCategory) {
            return res.status(404).json({ error: 'Không tìm thấy danh mục' });
        }
        res.json(updatedCategory);
    } catch (err) {
        res.status(400).json({ error: 'Lỗi khi cập nhật danh mục' });
    }
});

// 📌 API Xóa danh mục theo ID
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await Category.findByIdAndDelete(id);
        res.json({ message: 'Danh mục đã bị xóa' });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
});

module.exports = router;
