const connection = require('../config/db');

const Doctor = {
  getAll: (callback) => {
    connection.query("SELECT * FROM doctors", callback);
  },
  
  getById: (id, callback) => {
    connection.query("SELECT * FROM doctors WHERE id = ?", [id], callback);
  },
  
  create: (data, callback) => {
    connection.query("INSERT INTO doctors (name, specialty, availability) VALUES (?, ?, ?)", 
      [data.name, data.specialty, data.availability], callback);
  },

  update: (id, data, callback) => {
    connection.query("UPDATE doctors SET name = ?, specialty = ?, availability = ? WHERE id = ?", 
      [data.name, data.specialty, JSON.stringify(data.availability), id], callback);
  },

  delete: (id, callback) => {
    connection.query("DELETE FROM doctors WHERE id = ?", [id], callback);
  }
};

module.exports = Doctor;
