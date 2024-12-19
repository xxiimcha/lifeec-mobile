const EmergencyAlert = require('../models/emergencyAlertModel');

// Fetch emergency alerts by residentId
exports.getEmergencyAlertsByResident = async (req, res) => {
  const { residentId } = req.query;

  try {
    const alerts = await EmergencyAlert.find({ residentId });
    return res.status(200).json(alerts);
  } catch (error) {
    console.error('Error fetching emergency alerts:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// Create a new emergency alert
// Create a new emergency alert
exports.createEmergencyAlert = async (req, res) => {
  const { residentId, residentName, message } = req.body;

  // Validate input fields
  if (!residentId || !residentName || !message) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  try {
    const newAlert = new EmergencyAlert({
      residentId,
      residentName,
      message,
      timestamp: new Date(),
    });

    await newAlert.save();

    console.log('[INFO] Emergency alert created:', {
      residentId,
      residentName,
      message,
    });

    return res
      .status(201)
      .json({ message: 'Emergency alert created successfully' });
  } catch (error) {
    console.error('[ERROR] Failed to create emergency alert:', error);
    return res.status(500).json({ message: 'Failed to create emergency alert' });
  }
};

// Delete an emergency alert
exports.deleteEmergencyAlert = async (req, res) => {
  const { id } = req.params;

  try {
    await EmergencyAlert.findByIdAndDelete(id);
    return res.status(200).json({ message: 'Emergency alert deleted successfully' });
  } catch (error) {
    console.error('Error deleting emergency alert:', error);
    return res.status(500).json({ message: 'Failed to delete emergency alert' });
  }
};
