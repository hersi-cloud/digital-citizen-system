const dns = require('dns');

console.log('Resolving SRV record for cluster0.om6ytgs.mongodb.net...');

dns.resolveSrv('_mongodb._tcp.cluster0.om6ytgs.mongodb.net', (err, addresses) => {
    if (err) {
        console.error('Error resolving SRV:', err);
        return;
    }
    console.log('SRV Records found:');
    console.log(JSON.stringify(addresses, null, 2));
    
    // Construct standard connection string
    if (addresses && addresses.length > 0) {
        const hosts = addresses.map(a => `${a.name}:${a.port}`).join(',');
        const connectionString = `mongodb://hersi_db_user:<password>@${hosts}/?replicaSet=atlas-${addresses[0].name.split('-')[1]}-shard-0&ssl=true&authSource=admin`;
        console.log('\nSUGGESTED CONNECTION STRING:');
        console.log(connectionString);
    }
});
