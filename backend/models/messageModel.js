const mongoose = require('mongoose');

// Define the Message schema
const messageSchema = new mongoose.Schema({
  content: { type: String, required: true },
  isAdmin: { type: Boolean, required: true },
}, { timestamps: true }); // Timestamps for createdAt and updatedAt

// Create the Message model
const Message = mongoose.model('Message', messageSchema);

module.exports = Message;
