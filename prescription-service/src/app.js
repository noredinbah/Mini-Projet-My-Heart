const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const prescriptionRoutes = require('./routes/prescriptionRoutes');

// Middleware
const app = express();
app.use(bodyParser.json());

// Routes
app.use('/api/prescription', prescriptionRoutes);

// MongoDB connection
mongoose.connect('mongodb://localhost:27017/prescription-service', { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('Connected to MongoDB...'))
  .catch(err => console.error('Could not connect to MongoDB...', err));

const PORT = process.env.PORT || 5006;
app.listen(PORT, () => {
  console.log('Prescription service running on port ' + PORT);
});
