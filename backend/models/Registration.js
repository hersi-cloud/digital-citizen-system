const mongoose = require('mongoose');

const registrationSchema = mongoose.Schema(
    {
        user: {
            type: mongoose.Schema.Types.ObjectId,
            required: true,
            ref: 'User',
        },
        childFullName: {
            type: String,
            required: [true, 'Please add the child\'s full name'],
        },
        dob: {
            type: Date,
            required: [true, 'Please add Date of Birth'],
        },
        gender: {
            type: String,
            required: [true, 'Please select gender'],
            enum: ['Male', 'Female'],
        },
        placeOfBirth: {
            type: String,
            required: [true, 'Please add place of birth'],
        },
        fatherName: {
            type: String,
            required: [true, 'Please add father\'s name'],
        },
        motherName: {
            type: String,
            required: [true, 'Please add mother\'s name'],
        },
        status: {
            type: String,
            required: true,
            enum: ['Pending', 'Approved', 'Rejected'],
            default: 'Pending',
        },
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model('Registration', registrationSchema);
