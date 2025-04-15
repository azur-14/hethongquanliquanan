const express = require('express');
const Category = require('../models/Category');

const router = express.Router();

// API Lấy danh sách danh mục (menu)
router.get('/', async (req, res) => {
    try {
        const categories = await Category.find();
        res.json(categories);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
});

module.exports = router;
