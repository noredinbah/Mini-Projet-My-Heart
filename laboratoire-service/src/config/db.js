const mongoose = require('mongoose');

// MongoDB connection setup
mongoose.connect('mongodb://localhost:27017/laboratoire_service', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

const db = mongoose.connection;
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', () => {
  console.log('Connected to MongoDB for Laboratoire service');
});

