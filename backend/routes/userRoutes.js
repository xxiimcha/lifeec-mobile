const express = require('express');
const router = express.Router();
const { getUsers, addUser, editUser, deleteUser } = require('../controllers/user');

// Get all users, with optional userType filtering
router.get('/', getUsers);

// Add a new user
router.post('/', addUser);

// Edit an existing user by ID
router.put('/:id', editUser);

// Delete a user by ID
router.delete('/:id', deleteUser);

module.exports = router;
