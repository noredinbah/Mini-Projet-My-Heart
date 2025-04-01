const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const doctorRoutes = require('./src/routes/doctorRoutes');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use('/api', doctorRoutes);

const PORT = process.env.PORT || 5004;

app.listen(PORT, () => {
  console.log("MÃ©decin Service running on port ");
});
