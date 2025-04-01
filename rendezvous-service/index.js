const express = require('express');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const { connectDB } = require('./config/db');
const rendezvousRoutes = require('./routes/rendezvous');

dotenv.config();

const app = express();
app.use(bodyParser.json());

// Routes
app.use('/api/rendezvous', rendezvousRoutes);

// Start Server
const PORT = process.env.PORT || 5002;
app.listen(PORT, async () => {
  await connectDB();
  console.log("Rendezvous Service running on port ");
});
