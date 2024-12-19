const express = require('express');
const router = express.Router();
const {
  getEmergencyAlertsByResident,
  createEmergencyAlert,
  deleteEmergencyAlert,
} = require('../controllers/emergencyAlertController');

// Fetch emergency alerts for a resident
router.get('/', getEmergencyAlertsByResident);

// Create a new emergency alert
router.post('/', createEmergencyAlert);

// Delete an emergency alert by ID
router.delete('/:id', deleteEmergencyAlert);

module.exports = router;
