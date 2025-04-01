const laboratoireModel = require('./models/laboratoire');

// Implement gRPC service methods
const laboratoireService = {
  // Get laboratory results by ID
  getResultById: (call, callback) => {
    const id = call.request.id;
    laboratoireModel.findById(id, (err, result) => {
      if (err) {
        callback({
          code: grpc.status.NOT_FOUND,
          details: 'Not Found'
        });
      } else {
        callback(null, result);
      }
    });
  },

  // Create a new laboratory result
  createResult: (call, callback) => {
    const { patientId, testName, result, date } = call.request;

    const newResult = new laboratoireModel({
      patientId,
      testName,
      result,
      date
    });

    newResult.save((err, result) => {
      if (err) {
        callback({
          code: grpc.status.INTERNAL,
          details: 'Error saving result'
        });
      } else {
        callback(null, { message: 'Result created', resultId: result._id });
      }
    });
  }
};

module.exports = laboratoireService;
