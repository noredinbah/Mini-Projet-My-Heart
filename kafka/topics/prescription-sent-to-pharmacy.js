module.exports = {
    topic: 'prescription-sent-to-pharmacy',
    message: {
        prescriptionId: String,
        pharmacyId: String,
        status: String
    }
};
