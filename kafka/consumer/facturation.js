const kafka = require('kafka-node');
const consumer = new kafka.Consumer(new kafka.KafkaClient({ kafkaHost: 'localhost:9092' }), [
    { topic: 'prescription-created', partition: 0 }
], { autoCommit: true });

consumer.on('message', (message) => {
    const prescription = JSON.parse(message.value);
    console.log('Received prescription created event:', prescription);
    // Logic to create bill based on prescription
});

consumer.on('error', (error) => {
    console.error('Error in Kafka consumer:', error);
});
