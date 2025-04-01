const express = require('express');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const patientRoutes = require('./routes/patient');

dotenv.config();

const app = express();
app.use(bodyParser.json());

// Routes
app.use('/api/patients', patientRoutes);

// Start Server
const PORT = process.env.PORT || 5001;
app.listen(PORT, async () => {
    console.log("Patient Service running on port ");
});
