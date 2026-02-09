const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const asyncHandler = require('express-async-handler');
const User = require('../models/User');

// @desc    Register new user
// @route   POST /api/auth/register
// @access  Public
const registerUser = asyncHandler(async (req, res) => {
    const { email, password, role, fullName, birthPlace, address } = req.body;

    if (!email || !password || !fullName || !birthPlace || !address) {
        res.status(400);
        throw new Error('Please add all fields');
    }

    // Check if user exists
    const userExists = await User.findOne({ email });

    if (userExists) {
        res.status(400);
        throw new Error('User already exists');
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create user
    const user = await User.create({
        email,
        password: hashedPassword,
        role: role || 'User',
        fullName,
        birthPlace,
        address,
        profileImage: req.body.profileImage || '',
    });

    if (user) {
        res.status(201).json({
            _id: user.id,
            email: user.email,
            role: user.role,
            token: generateToken(user._id),
        });
    } else {
        res.status(400);
        throw new Error('Invalid user data');
    }
});

// @desc    Authenticate a user
// @route   POST /api/auth/login
// @access  Public
const loginUser = asyncHandler(async (req, res) => {
    const { email, password } = req.body;

    // Check for user email
    const user = await User.findOne({ email });

    if (user && (await bcrypt.compare(password, user.password))) {
        res.json({
            _id: user.id,
            email: user.email,
            role: user.role,
            fullName: user.fullName,
            address: user.address,
            birthPlace: user.birthPlace,
            profileImage: user.profileImage,
            token: generateToken(user._id),
        });
    } else {
        res.status(401);
        throw new Error('Invalid credentials');
    }
});

// @desc    Get user data
// @route   GET /api/auth/me
// @access  Private
const getMe = asyncHandler(async (req, res) => {
    
    // User is already attached to req via middleware
    /* 
       Note: The requirements didn't explicitly ask for this endpoint, 
       but it's standard for verifying auth state.
    */
    res.status(200).json(req.user);
});

// Generate JWT
const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '30d',
    });
};

// @desc    Get all users (Admin)
// @route   GET /api/auth/users
// @access  Private/Admin
const getAllUsers = asyncHandler(async (req, res) => {
    const users = await User.find({}).select('-password');
    res.json(users);
});

// @desc    Update user profile
// @route   PUT /api/auth/profile
// @access  Private
const updateUserProfile = asyncHandler(async (req, res) => {
    const user = await User.findById(req.user._id);

    if (user) {
        user.fullName = req.body.fullName || user.fullName;
        user.email = req.body.email || user.email;
        user.address = req.body.address || user.address;
        user.birthPlace = req.body.birthPlace || user.birthPlace;
        user.profileImage = req.body.profileImage || user.profileImage;

        if (req.body.password) {
            const salt = await bcrypt.genSalt(10);
            user.password = await bcrypt.hash(req.body.password, salt);
        }

        const updatedUser = await user.save();

        res.json({
            _id: updatedUser._id,
            email: updatedUser.email,
            role: updatedUser.role,
            fullName: updatedUser.fullName,
            birthPlace: updatedUser.birthPlace,
            address: updatedUser.address,
            profileImage: updatedUser.profileImage,
            token: generateToken(updatedUser._id),
        });
    } else {
        res.status(404);
        throw new Error('User not found');
    }
});

// @desc    Update any user (Admin)
// @route   PUT /api/auth/users/:id
// @access  Private/Admin
const updateUser = asyncHandler(async (req, res) => {
    const user = await User.findById(req.params.id);

    if (user) {
        user.fullName = req.body.fullName || user.fullName;
        user.email = req.body.email || user.email;
        user.address = req.body.address || user.address;
        user.birthPlace = req.body.birthPlace || user.birthPlace;
        user.role = req.body.role || user.role;
        // Admin can update others' profiles, potentially including image if needed, 
        // but primarily data.
        
        const updatedUser = await user.save();

        res.json({
            _id: updatedUser._id,
            email: updatedUser.email,
            role: updatedUser.role,
            fullName: updatedUser.fullName,
            birthPlace: updatedUser.birthPlace,
            address: updatedUser.address,
            profileImage: updatedUser.profileImage,
        });
    } else {
        res.status(404);
        throw new Error('User not found');
    }
});

// @desc    Delete user
// @route   DELETE /api/auth/users/:id
// @access  Private/Admin
const deleteUser = asyncHandler(async (req, res) => {
    const user = await User.findById(req.params.id);

    if (user) {
        await User.deleteOne({ _id: req.params.id });
        res.json({ message: 'User removed' });
    } else {
        res.status(404);
        throw new Error('User not found');
    }
});

module.exports = {
    registerUser,
    loginUser,
    getMe,
    getAllUsers,
    updateUserProfile,
    updateUser,
    deleteUser,
};
