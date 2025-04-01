const kafka = require('kafka-node');
const producer = new kafka.Producer(new kafka.KafkaClient({ kafkaHost: 'localhost:9092' }));

const sendPrescriptionCreatedEvent = (prescription) => {
    const payload = [{
        topic: 'prescription-created',
        messages: JSON.stringify(prescription),
        partition: 0
    }];
    
    producer.send(payload, (error, data) => {
        if (error) {
            console.error('Error sending message to Kafka', error);
        } else {
            console.log('Message sent to Kafka:', data);
        }
    });
};

module.exports = { sendPrescriptionCreatedEvent };
