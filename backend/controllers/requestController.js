const asyncHandler = require('express-async-handler');
const Request = require('../models/Request');

// @desc    Create a new request (ID or Birth Cert)
// @route   POST /api/requests
// @access  Private
const createRequest = asyncHandler(async (req, res) => {
    const { type, details } = req.body;

    if (!type || !details) {
        res.status(400);
        throw new Error('Please add type and details');
    }

    const request = await Request.create({
        user: req.user.id,
        type,
        details,
        status: 'Starting'
    });

    res.status(201).json(request);
});

// @desc    Get user requests
// @route   GET /api/requests
// @access  Private
const getMyRequests = asyncHandler(async (req, res) => {
    console.log(`Fetching requests for user: ${req.user.id}`);
    const requests = await Request.find({ user: req.user.id }).sort({ createdAt: -1 });
    console.log(`Found ${requests.length} requests`);
    res.status(200).json(requests);
});

// @desc    Get all requests (Admin only)
// @route   GET /api/requests/all
// @access  Private (Admin)
const getAllRequests = asyncHandler(async (req, res) => {
    if (req.user.role !== 'Admin') {
        res.status(403);
        throw new Error('Not authorized as admin');
    }
    const requests = await Request.find().populate('user', 'fullName email').sort({ createdAt: -1 });
    res.status(200).json(requests);
});

// @desc    Update request status (Admin only)
// @route   PUT /api/requests/:id
// @access  Private (Admin)
const updateRequestStatus = asyncHandler(async (req, res) => {
    if (req.user.role !== 'Admin') {
        res.status(403);
        throw new Error('Not authorized as admin');
    }

    const request = await Request.findById(req.params.id);

    if (!request) {
        res.status(404);
        throw new Error('Request not found');
    }

    request.status = req.body.status || request.status;
    request.adminNote = req.body.adminNote || request.adminNote;
    
    // Simplification: In a real app, you might generate the PDF and save status as Completed here
    // For this prototype, we assume if Completed, the frontend will generate/download the PDF based on stored details.

    const updatedRequest = await request.save();
    res.status(200).json(updatedRequest);
});

module.exports = {
    createRequest,
    getMyRequests,
    getAllRequests,
    updateRequestStatus,
};
