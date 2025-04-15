const express = require('express');
const Category = require('../models/Category');

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Categories
 *   description: API quản lý danh mục món ăn
 */

/**
 * @swagger
 * /api/categories:
 *   get:
 *     summary: Lấy danh sách danh mục
 *     tags: [Categories]
 *     responses:
 *       200:
 *         description: Danh sách các danh mục món ăn
 *       500:
 *         description: Lỗi server
 */
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
