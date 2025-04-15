const express = require('express');
const router = express.Router();
const Table = require('../models/Table');

// Lấy danh sách tất cả bàn (menu, openTable, orderPage)
router.get('/', async (req, res) => {
    try {
        const tables = await Table.find();
        res.json(tables);
    } catch (err) {
        res.status(500).json({ error: 'Lỗi khi lấy danh sách bàn' });
    }
});

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
