const mongoose = require('mongoose');

const connectDB = async () => {
    try {
        const conn = await mongoose.connect(process.env.MONGO_URI, {
            // Fix for Render/Atlas ENOTFOUND error
            family: 4, 
        });
        console.log(`MongoDB Connected: ${conn.connection.host}`);
        
        // DEBUG: Print full connection string for Render
        try {
            const client = conn.connection.getClient();
            const hosts = client.topology.s.options.hosts.map(h => `${h.host}:${h.port}`).join(',');
            console.log(`\n✅ STANDARD CONNECTION STRING FOR RENDER:`);
            console.log(`mongodb://hersi_db_user:Eq9cpO630LkrCOtk@${hosts}/?ssl=true&authSource=admin&replicaSet=atlas-${process.env.MONGO_URI.split('@')[1].split('.')[0].substring(0,7)}-shard-0`);
            console.log(`\n`);
        } catch (err) {
            console.log("Could not extract full string, check manually.");
        }
    } catch (error) {
        console.error(`Error: ${error.message}`);
        process.exit(1);
    }
};

module.exports = connectDB;
