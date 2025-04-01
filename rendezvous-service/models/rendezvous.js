const { connection } = require('../config/db');

// Create a new rendezvous
const createRendezvous = (patientId, doctorId, date, time, callback) => {
  const query = 'INSERT INTO rendezvous (patient_id, doctor_id, date, time) VALUES (?, ?, ?, ?)';
  connection.query(query, [patientId, doctorId, date, time], (err, result) => {
    if (err) {
      console.error('Error creating rendezvous:', err);
      callback(err, null);
    } else {
      callback(null, result);
    }
  });
};

// Get all rendezvous for a specific patient
const getRendezvousByPatient = (patientId, callback) => {
  const query = 'SELECT * FROM rendezvous WHERE patient_id = ?';
  connection.query(query, [patientId], (err, rows) => {
    if (err) {
      console.error('Error fetching rendezvous:', err);
      callback(err, null);
    } else {
      callback(null, rows);
    }
  });
};

// Get all rendezvous for a specific doctor
const getRendezvousByDoctor = (doctorId, callback) => {
  const query = 'SELECT * FROM rendezvous WHERE doctor_id = ?';
  connection.query(query, [doctorId], (err, rows) => {
    if (err) {
      console.error('Error fetching rendezvous:', err);
      callback(err, null);
    } else {
      callback(null, rows);
    }
  });
};

// Update an existing rendezvous
const updateRendezvous = (rendezvousId, newDate, newTime, callback) => {
  const query = 'UPDATE rendezvous SET date = ?, time = ? WHERE id = ?';
  connection.query(query, [newDate, newTime, rendezvousId], (err, result) => {
    if (err) {
      console.error('Error updating rendezvous:', err);
      callback(err, null);
    } else {
      callback(null, result);
    }
  });
};

// Delete a rendezvous
const deleteRendezvous = (rendezvousId, callback) => {
  const query = 'DELETE FROM rendezvous WHERE id = ?';
  connection.query(query, [rendezvousId], (err, result) => {
    if (err) {
      console.error('Error deleting rendezvous:', err);
      callback(err, null);
    } else {
      callback(null, result);
    }
  });
};

module.exports = {
  createRendezvous,
  getRendezvousByPatient,
  getRendezvousByDoctor,
  updateRendezvous,
  deleteRendezvous
};
