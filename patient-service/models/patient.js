const { query } = require('../config/db');

// Create a new patient
const createPatient = async (name, email, dob, medicalHistory) => {
    const sql = 'INSERT INTO patients (name, email, dob, medical_history) VALUES (?, ?, ?, ?)';
    return query(sql, [name, email, dob, medicalHistory]);
};

// Get all patients
const getAllPatients = async () => {
    const sql = 'SELECT * FROM patients';
    return query(sql);
};

// Get a specific patient by ID
const getPatientById = async (id) => {
    const sql = 'SELECT * FROM patients WHERE id = ?';
    return query(sql, [id]);
};

// Update a patient's data
const updatePatient = async (id, name, email, dob, medicalHistory) => {
    const sql = 'UPDATE patients SET name = ?, email = ?, dob = ?, medical_history = ? WHERE id = ?';
    return query(sql, [name, email, dob, medicalHistory, id]);
};

// Delete a patient
const deletePatient = async (id) => {
    const sql = 'DELETE FROM patients WHERE id = ?';
    return query(sql, [id]);
};

module.exports = { createPatient, getAllPatients, getPatientById, updatePatient, deletePatient };
