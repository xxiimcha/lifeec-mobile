const express = require('express');
const router = express.Router();
const messageController = require('../controllers/messageController');

// Define routes for messages
router.get('/', messageController.getAllMessages);
router.post('/', messageController.createMessage);

module.exports = router;
