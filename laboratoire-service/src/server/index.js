const grpc = require('grpc');
const path = require('path');
const laboratoireService = require('./grpc-server');
const PROTO_PATH = path.join(__dirname, 'proto', 'laboratoire.proto');

// Load gRPC service definition
const proto = grpc.load(PROTO_PATH);
const server = new grpc.Server();

// Add service to the server
server.addService(proto.LaboratoireService.service, laboratoireService);

// Start gRPC server
const PORT = process.env.PORT || 5009;
server.bind('0.0.0.0:' + PORT, grpc.ServerCredentials.createInsecure());
console.log('Laboratoire gRPC server running on port ' + PORT);
server.start();
