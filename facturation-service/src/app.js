const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const facturationRoutes = require('./routes/facturationRoutes');

// Middleware
const app = express();
app.use(bodyParser.json());

// Routes
app.use('/api/facturation', facturationRoutes);

// MySQL connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'password',  
  database: 'facturation_service'
});

db.connect(err => {
  if (err) {
    console.error('Error connecting to the database: ' + err.stack);
    return;
  }
  console.log('Connected to MySQL as ID ' + db.threadId);
});

const PORT = process.env.PORT || 5008;
app.listen(PORT, () => {
  console.log('Facturation service running on port ' + PORT);
});

module.exports = db;
