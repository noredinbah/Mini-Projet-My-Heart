const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const pharmacieRoutes = require('./routes/pharmacieRoutes');

// Middleware
const app = express();
app.use(bodyParser.json());

// Routes
app.use('/api/pharmacie', pharmacieRoutes);

// MongoDB connection
mongoose.connect('mongodb://localhost:27017/pharmacie-service', { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('Connected to MongoDB...'))
  .catch(err => console.error('Could not connect to MongoDB...', err));

const PORT = process.env.PORT || 5007;
app.listen(PORT, () => {
  console.log('Pharmacie service running on port ' + PORT);
});
