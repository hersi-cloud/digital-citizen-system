const asyncHandler = require('express-async-handler');
const Registration = require('../models/Registration');

// @desc    Get all registrations
// @route   GET /api/registrations
// @access  Private
const getRegistrations = asyncHandler(async (req, res) => {
    let registrations;
    
    // If Admin, return all. If User, return only their own.
    if (req.user.role === 'Admin') {
        registrations = await Registration.find().populate('user', 'email');
    } else {
        registrations = await Registration.find({ user: req.user.id });
    }

    res.status(200).json(registrations);
});

// @desc    Create new registration
// @route   POST /api/registrations
// @access  Private
const createRegistration = asyncHandler(async (req, res) => {
    const {
        childFullName,
        dob,
        gender,
        placeOfBirth,
        fatherName,
        motherName,
    } = req.body;

    if (!childFullName || !dob || !gender || !placeOfBirth || !fatherName || !motherName) {
        res.status(400);
        throw new Error('Please add all required fields');
    }

    const registration = await Registration.create({
        user: req.user.id,
        childFullName,
        dob,
        gender,
        placeOfBirth,
        fatherName,
        motherName,
    });

    res.status(201).json(registration);
});

// @desc    Update registration
// @route   PUT /api/registrations/:id
// @access  Private
const updateRegistration = asyncHandler(async (req, res) => {
    const registration = await Registration.findById(req.params.id);

    if (!registration) {
        res.status(404);
        throw new Error('Registration not found');
    }

    // Check for user
    if (!req.user) {
        res.status(401);
        throw new Error('User not found');
    }

    // Make sure the logged in user matches the registration user OR is Admin
    if (registration.user.toString() !== req.user.id && req.user.role !== 'Admin') {
        res.status(401);
        throw new Error('User not authorized');
    }

    const updatedRegistration = await Registration.findByIdAndUpdate(
        req.params.id,
        req.body,
        { new: true }
    );

    res.status(200).json(updatedRegistration);
});

// @desc    Delete registration
// @route   DELETE /api/registrations/:id
// @access  Private
const deleteRegistration = asyncHandler(async (req, res) => {
    const registration = await Registration.findById(req.params.id);

    if (!registration) {
        res.status(404);
        throw new Error('Registration not found');
    }

    // Check for user
    if (!req.user) {
        res.status(401);
        throw new Error('User not found');
    }

    // Make sure the logged in user matches the registration user OR is Admin
    if (registration.user.toString() !== req.user.id && req.user.role !== 'Admin') {
        res.status(401);
        throw new Error('User not authorized');
    }

    await registration.deleteOne();

    res.status(200).json({ id: req.params.id });
});

module.exports = {
    getRegistrations,
    createRegistration,
    updateRegistration,
    deleteRegistration,
};
