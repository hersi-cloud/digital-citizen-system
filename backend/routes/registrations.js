const express = require('express');
const router = express.Router();
const {
    getRegistrations,
    createRegistration,
    updateRegistration,
    deleteRegistration,
} = require('../controllers/registrationController');
const { protect } = require('../middleware/authMiddleware');

const { validateRegistrationEntry } = require('../middleware/validationMiddleware');

router.route('/').get(protect, getRegistrations).post(protect, validateRegistrationEntry, createRegistration);
router.route('/:id').put(protect, updateRegistration).delete(protect, deleteRegistration);

module.exports = router;
