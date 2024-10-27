const Message = require('../models/messageModel');

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
  const { content, isAdmin } = req.body;
  
  const newMessage = new Message({
    content,
    isAdmin,
  });

  try {
    const savedMessage = await newMessage.save();
    res.status(201).json(savedMessage);
  } catch (error) {
    res.status(400).json({ message: 'Error saving message', error });
  }
};

module.exports = {
  getAllMessages,
  createMessage,
};
