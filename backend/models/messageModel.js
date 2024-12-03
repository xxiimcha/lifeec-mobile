const mongoose = require('mongoose');

// Define the Message schema
const messageSchema = new mongoose.Schema(
  {
    senderId: {
      type: String, // Changed from Schema.Types.ObjectId to String
      required: true,
    },
    receiverId: {
      type: String, // Changed from Schema.Types.ObjectId to String
      required: true,
    },
    text: {
      type: String,
      required: true,
    },
    time: {
      type: Date,
      default: Date.now, // Automatically set to current date and time
    },
    isRead: {
      type: Boolean,
      default: false, // Optional: flag to track if the message has been read
    },
  },
  { timestamps: true } // Adds createdAt and updatedAt fields automatically
);

// Create the Message model
const Message = mongoose.model('Message', messageSchema);

module.exports = Message;
