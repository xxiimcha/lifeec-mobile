const User = require('../models/user');

// Get all users based on userType filter
const getUsers = async (req, res) => {
  const { userType } = req.query; // Assume userType is passed as a query parameter

  try {
    // Fetch users based on userType if specified
    let users;
    if (userType === 'Family Member') {
      users = await User.find({ userType: 'Nurse' });
    } else if (userType === 'Nurse') {
      users = await User.find({ userType: { $in: ['Family Member', 'Nutritionist'] } });
    } else if (userType === 'Nutritionist') {
      users = await User.find({ userType: 'Nurse' });
    } else {
      users = await User.find(); // If no filter, fetch all users
    }

    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ message: 'Failed to get users' });
  }
};

// Add new user
const addUser = async (req, res) => {
  const { name, subtitle, userType } = req.body;

  if (!name || !userType) {
    return res.status(400).json({ message: 'Name and userType are required' });
  }

  try {
    const newUser = new User({
      name,
      subtitle,
      userType,
    });
    await newUser.save();
    res.status(201).json(newUser);
  } catch (error) {
    res.status(500).json({ message: 'Failed to add user' });
  }
};

// Edit user
const editUser = async (req, res) => {
  const { id } = req.params;
  const { name, subtitle, userType } = req.body;

  try {
    const user = await User.findById(id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Update fields
    user.name = name || user.name;
    user.subtitle = subtitle || user.subtitle;
    user.userType = userType || user.userType;
    await user.save();

    res.status(200).json(user);
  } catch (error) {
    console.error('Failed to update user:', error);
    res.status(500).json({ message: 'Failed to edit user' });
  }
};

// Delete user
const deleteUser = async (req, res) => {
  const { id } = req.params;

  try {
    const user = await User.findByIdAndDelete(id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(204).send(); // Successfully deleted
  } catch (error) {
    console.error('Failed to delete user:', error);
    res.status(500).json({ message: 'Failed to delete user' });
  }
};

module.exports = {
  getUsers,
  addUser,
  editUser,
  deleteUser,
};
