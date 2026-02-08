const express = require('express');
const router = express.Router();
const {
    registerUser,
    loginUser,
    getMe,
    getAllUsers,
    updateUserProfile,
    updateUser,
    deleteUser,
} = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

const { validateUserRegistration } = require('../middleware/validationMiddleware');

router.post('/register', validateUserRegistration, registerUser);
router.post('/login', loginUser);
router.get('/me', protect, getMe);
router.get('/users', protect, getAllUsers);
router.put('/profile', protect, updateUserProfile);
router.put('/users/:id', protect, updateUser);
router.delete('/users/:id', protect, deleteUser);

module.exports = router;
