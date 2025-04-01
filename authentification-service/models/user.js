// models/user.js
const connectDB = require('../config/db');
const bcrypt = require('bcryptjs');

const User = {
    createUser: async (name, email, password) => {
        const hashedPassword = await bcrypt.hash(password, 10);
        return new Promise((resolve, reject) => {
            const connection = connectDB(); // Get DB connection

            const query = 'INSERT INTO users (name, email, password) VALUES (?, ?, ?)';
            connection.query(query, [name, email, hashedPassword], (err, result) => {
                if (err) {
                    console.error('Error in createUser:', err.message); // Log error message
                    reject(err);
                } else {
                    resolve(result);
                }
                connection.end(); // Close the connection after query
            });
        });
    },

    findByEmail: (email) => {
        return new Promise((resolve, reject) => {
            const connection = connectDB(); // Get DB connection

            const query = 'SELECT * FROM users WHERE email = ?';
            connection.query(query, [email], (err, result) => {
                if (err) {
                    console.error('Error in findByEmail:', err.message); // Log error message
                    reject(err);
                } else if (result.length === 0) {
                    resolve(null);  // Return null if no user is found
                } else {
                    resolve(result[0]);
                }
                connection.end(); // Close the connection after query
            });
        });
    },

    findById: (id) => {
        return new Promise((resolve, reject) => {
            const connection = connectDB(); // Get DB connection

            const query = 'SELECT id, name, email FROM users WHERE id = ?';
            connection.query(query, [id], (err, result) => {
                if (err) {
                    console.error('Error in findById:', err.message); // Log error message
                    reject(err);
                } else if (result.length === 0) {
                    resolve(null);  // Return null if no user is found
                } else {
                    resolve(result[0]);
                }
                connection.end(); // Close the connection after query
            });
        });
    }
};

module.exports = User;
