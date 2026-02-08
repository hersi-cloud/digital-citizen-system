const mongoose = require('mongoose');

const requestSchema = mongoose.Schema(
    {
        user: {
            type: mongoose.Schema.Types.ObjectId,
            required: true,
            ref: 'User',
        },
        type: {
            type: String,
            required: true,
            enum: ['National ID', 'Birth Certificate'],
        },
        status: {
            type: String,
            required: true,
            enum: ['Starting', 'In Progress', 'Completed', 'Rejected'],
            default: 'Starting',
        },
        details: {
            type: Object, // Stores specific details like fullName, DOB, photoUrl, etc.
            required: true,
        },
        adminNote: {
            type: String, // Reason for rejection or notes
        }
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model('Request', requestSchema);
