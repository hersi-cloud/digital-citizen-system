const { check, validationResult } = require('express-validator');

const validateUserRegistration = [
    check('email', 'Please include a valid email').isEmail(),
    check('password', 'Password must be 6 or more characters').isLength({ min: 6 }),
    (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }
        next();
    }
];

const validateRegistrationEntry = [
    check('childFullName', 'Child name is required').not().isEmpty(),
    check('dob', 'Date of birth is required').not().isEmpty(),
    check('gender', 'Gender is required').isIn(['Male', 'Female']),
    check('placeOfBirth', 'Place of birth is required').not().isEmpty(),
    check('fatherName', 'Father name is required').not().isEmpty(),
    check('motherName', 'Mother name is required').not().isEmpty(),
    (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }
        next();
    }
];

module.exports = {
    validateUserRegistration,
    validateRegistrationEntry
};
