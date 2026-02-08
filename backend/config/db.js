const mongoose = require('mongoose');

const connectDB = async () => {
    try {
        // Force IPv4 and add timeouts
        const conn = await mongoose.connect(process.env.MONGO_URI.replace('localhost', '127.0.0.1'), {
            serverSelectionTimeoutMS: 5000, // Fail after 5 seconds if no server
             socketTimeoutMS: 45000,
        });
        console.log(`MongoDB Connected: ${conn.connection.host}`);
    } catch (error) {
        console.error(`Error: ${error.message}`);
        process.exit(1);
    }
};

module.exports = connectDB;
