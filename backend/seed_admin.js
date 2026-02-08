const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./models/User');
const dotenv = require('dotenv');

dotenv.config();

const connectDB = async () => {
    try {
        console.log(`Connecting to: ${process.env.MONGO_URI.substring(0, 20)}...`);
        await mongoose.connect(process.env.MONGO_URI);
        console.log('MongoDB Connected');
    } catch (err) {
        console.error('Connection Error:', err);
        process.exit(1);
    }
}

const seedAdmin = async () => {
    await connectDB();

    const email = 'admin@example.com';
    const password = '123456';
    
    try {
        const userExists = await User.findOne({ email });
        if (userExists) {
            console.log('Admin user already exists.');
            process.exit(0);
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        await User.create({
            email,
            password: hashedPassword,
            role: 'Admin',
            fullName: 'System Administrator',
            birthPlace: 'Mogadishu',
            address: 'Hodan District',
            profileImage: '',
        });

        console.log('Admin User Created Successfully!');
    } catch (error) {
        console.error('Error creating admin:', error);
    }
    process.exit(0);
};

seedAdmin();
