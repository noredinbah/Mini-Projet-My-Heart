module.exports = {
    topic: 'prescription-created',
    message: {
        prescriptionId: String,
        patientId: String,
        doctorId: String,
        medication: String,
        dosage: String,
        createdAt: Date
    }
};
