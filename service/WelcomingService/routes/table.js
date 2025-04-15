const express = require('express');
const router = express.Router();
const Table = require('../models/Table');

/**
 * @swagger
 * /api/table:
 *   get:
 *     summary: Lấy danh sách tất cả bàn
 *     tags: [Table]
 *     responses:
 *       200:
 *         description: Danh sách bàn
 */
// Lấy danh sách tất cả bàn (menu, openTable, orderPage)
router.get('/', async (req, res) => {
    try {
        const tables = await Table.find();
        res.json(tables);
    } catch (err) {
        res.status(500).json({ error: 'Lỗi khi lấy danh sách bàn' });
    }
});

/**
 * @swagger
 * /api/table/{id}:
 *   put:
 *     summary: Cập nhật thông tin bàn theo _id
 *     tags: [Tables]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               table_id:
 *                 type: number
 *               table_name:
 *                 type: string
 *               status:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 *       404:
 *         description: Không tìm thấy bàn
 */
// Cập nhật thông tin bàn (openTable)
router.put('/:id', async (req, res) => {
    try {
        const { table_id, table_name, status } = req.body;

        const updatedTable = await Table.findByIdAndUpdate(
            req.params.id,
            { table_id, table_name, status },
            { new: true }
        );

        if (!updatedTable) {
            return res.status(404).json({ error: 'Không tìm thấy bàn' });
        }

        res.json(updatedTable);
    } catch (err) {
        res.status(400).json({ error: 'Lỗi khi cập nhật thông tin bàn' });
    }
});

/**
 * @swagger
 * /api/table/{tableId}:
 *   patch:
 *     summary: Cập nhật trạng thái bàn theo table_id
 *     tags: [Tables]
 *     parameters:
 *       - in: path
 *         name: tableId
 *         required: true
 *         schema:
 *           type: number
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
 *         description: Không tìm thấy bàn
 */
// Cập nhật trạng thái bàn theo tableId (bill)
router.patch('/:tableId', async (req, res) => {
    try {
      const updated = await Table.findOneAndUpdate(
        { table_id: req.params.tableId },
        { status: req.body.status },
        { new: true }
      );
  
      if (!updated) {
        return res.status(404).json({ error: 'Không tìm thấy bàn với table_id này' });
      }
  
      res.status(200).json(updated);
    } catch (err) {
      console.error("Lỗi cập nhật trạng thái bàn:", err);
      res.status(500).json({ error: 'Lỗi server' });
    }
});
  
module.exports = router;
