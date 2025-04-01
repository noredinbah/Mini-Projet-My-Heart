module.exports = {
    topic: 'bill-created',
    message: {
        billId: String,
        prescriptionId: String,
        amount: Number,
        patientId: String,
        createdAt: Date
    }
};
