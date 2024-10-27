const User = require('../models/user');
const jwt = require('jsonwebtoken');

// Sign Up
exports.signup = async (req, res) => {
  const { name, email, password } = req.body;

  // Check if all required fields are provided
  if (!name || !email || !password) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  try {
    // Create new user with userType as "Family Member"
    const user = new User({ name, email, password, userType: 'Family Member' });
    
    // Log for debugging purposes
    console.log('User to be saved:', user);

    // Save the user
    await user.save();
    res.status(201).json({ message: 'User created successfully' });
  } catch (error) {
    if (error.code === 11000) { // Duplicate email error (MongoDB duplicate key error)
      return res.status(400).json({ message: 'Email already in use' });
    }
    
    // Log validation errors
    console.error('Error creating user:', error);
    res.status(400).json({ error: error.message });
  }
};

// Sign In
exports.signin = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }

  try {
    const user = await User.findOne({ email });
    if (!user || !(await user.comparePassword(password))) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign({ userId: user._id, userType: user.userType }, process.env.JWT_SECRET, { expiresIn: '1h' });
    
    // Send userType in response
    res.json({ token, userType: user.userType });
  } catch (error) {
    console.error('Sign in error:', error);
    res.status(500).json({ error: error.message });
  }
};
