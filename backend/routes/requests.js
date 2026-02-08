const express = require('express');
const router = express.Router();
const {
    createRequest,
    getMyRequests,
    getAllRequests,
    updateRequestStatus,
} = require('../controllers/requestController');
const { protect } = require('../middleware/authMiddleware');

router.post('/', protect, createRequest);
router.get('/', protect, getMyRequests);

// Admin Routes
router.get('/all', protect, getAllRequests);
router.put('/:id', protect, updateRequestStatus);

module.exports = router;
