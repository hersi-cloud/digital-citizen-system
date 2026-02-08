const mongoose = require('mongoose');
const dotenv = require('dotenv');

dotenv.config();

const extractUrl = async () => {
    try {
        console.log('Connecting to MongoDB locally...');
        
        // This is the SRV link we know works locally
        const uri = "mongodb+srv://hersi_db_user:Eq9cpO630LkrCOtk@cluster0.om6ytgs.mongodb.net/?appName=Cluster0"; 
        
        await mongoose.connect(uri);
        console.log('Connected! Inspecting topology...');
        
        const client = mongoose.connection.getClient();
        
        // Try multiple ways to find the hosts
        let hosts = [];
        
        if (client.topology && client.topology.s && client.topology.s.options && client.topology.s.options.hosts) {
            hosts = client.topology.s.options.hosts;
        } else if (client.s && client.s.options && client.s.options.hosts) {
            hosts = client.s.options.hosts;
        }

        if (hosts.length > 0) {
             const hostString = hosts.map(h => `${h.host}:${h.port}`).join(',');
             console.log('\n--- SUCCESS! HERE IS THE LONG URL FOR RENDER ---');
             // Constructing the string
             console.log(`mongodb://hersi_db_user:Eq9cpO630LkrCOtk@${hostString}/?ssl=true&authSource=admin`);
             console.log('------------------------------------------------\n');
        } else {
             console.log('Could not find hosts in topology. Dumping client keys:');
             console.log(Object.keys(client));
        }

        process.exit(0);
    } catch (error) {
        console.error('Error:', error.message);
        process.exit(1);
    }
};

extractUrl();
