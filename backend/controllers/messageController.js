const Message = require('../models/messageModel');
const mongoose = require('mongoose');
// Fetch all messages
const getAllMessages = async (req, res) => {
  try {
    const messages = await Message.find();
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching messages', error });
  }
};

// Create a new message

const createMessage = async (req, res) => {
  try {
    const { senderId, receiverId, text, time, isRead } = req.body;

    // Validate required fields
    if (!senderId || !receiverId || !text) {
      return res.status(400).json({
        message: "Validation failed",
        errors: {
          senderId: !senderId ? "Sender ID is required" : undefined,
          receiverId: !receiverId ? "Receiver ID is required" : undefined,
          text: !text ? "Text is required" : undefined,
        },
      });
    }

    // Convert senderId and receiverId to ObjectId
    const messageData = {
      senderId: new mongoose.Types.ObjectId(senderId), // Ensure ObjectId
      receiverId: new mongoose.Types.ObjectId(receiverId), // Ensure ObjectId
      text,
      time: time || Date.now(),
      isRead: isRead || false,
    };

    console.log("Saving message:", messageData); // Debug log

    // Create and save the new message
    const newMessage = new Message(messageData);
    const savedMessage = await newMessage.save();

    res.status(201).json(savedMessage); // Return the saved message
  } catch (error) {
    console.error("Error saving message:", error);
    res.status(500).json({
      message: "Failed to save message",
      error: error.message,
    });
  }
};

// Fetch messages between two users
const getMessagesByUsers = async (req, res) => {
  try {
    const { senderId, receiverId } = req.query;

    // Validate query parameters
    if (!senderId || !receiverId) {
      return res.status(400).json({
        message: "Validation failed",
        errors: {
          senderId: !senderId ? "Sender ID is required" : undefined,
          receiverId: !receiverId ? "Receiver ID is required" : undefined,
        },
      });
    }

    // Fetch messages where senderId and receiverId match either direction
    const messages = await Message.find({
      $or: [
        { senderId, receiverId }, // Sender to receiver
        { senderId: receiverId, receiverId: senderId }, // Receiver to sender
      ],
    }).sort({ time: 1 }); // Sort by time in ascending order

    res.status(200).json(messages);
  } catch (error) {
    console.error("Error fetching messages:", error);
    res.status(500).json({ message: 'Error fetching messages', error });
  }
};

module.exports = {
  getAllMessages,
  createMessage,
  getMessagesByUsers,
};
