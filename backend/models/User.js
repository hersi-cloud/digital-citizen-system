const mongoose = require('mongoose');

const userSchema = mongoose.Schema(
    {
        email: {
            type: String,
            required: [true, 'Please add an email'],
            unique: true,
        },
        password: {
            type: String,
            required: [true, 'Please add a password'],
        },
        role: {
            type: String,
            required: true,
            enum: ['User', 'Admin'],
            default: 'User',
        },
        fullName: {
            type: String,
            required: [true, 'Please add a full name'],
        },
        birthPlace: {
            type: String,
            required: [true, 'Please add a place of birth'],
        },
        address: {
            type: String,
            required: [true, 'Please add an address'],
        },
        profileImage: {
            type: String,
            required: false,
            default: '',
        },
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model('User', userSchema);
