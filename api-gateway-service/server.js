const express = require('express');
const axios = require('axios');
const app = express();

// Set up routes for each service
app.use(express.json());

// Proxy requests to the backend services
const services = {
    'auth-service': 'http://auth-service:5000',
    'patient-service': 'http://patient-service:5001',
    'prescription-service': 'http://prescription-service:5002',
    'pharmacie-service': 'http://pharmacie-service:5003',
    'facturation-service': 'http://facturation-service:5004',
    'laboratoire-service': 'http://laboratoire-service:5005',
    'notification-service': 'http://notification-service:5006',
    'dossier-medical-service': 'http://dossier-medical-service:5007',
    'medecin-service': 'http://medecin-service:5008',
};

// Function to handle proxying requests to the correct service
app.all('/api/*', async (req, res) => {
    const service = req.url.split('/')[2];  // Extract service from URL path
    if (services[service]) {
        const url = services[service] + req.url.replace(`/api/${service}`, '');
        try {
            const response = await axios({
                method: req.method,
                url: url,
                data: req.body,
                headers: req.headers
            });
            res.status(response.status).send(response.data);
        } catch (error) {
            res.status(error.response?.status || 500).send(error.message);
        }
    } else {
        res.status(404).send('Service not found');
    }
});

// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`API Gateway is listening on port ${PORT}`);
});