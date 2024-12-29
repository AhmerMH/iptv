const express = require('express');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const app = express();

app.use(
  cors({
    origin: 'http://localhost:5173',
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'x-refresh-token'],
  })
);

const users = [
  {
    id: 'USR123456',
    firstName: 'John',
    lastName: 'Smith',
    email: 'john.smith@example.com',
    address1: '123 Tech Street',
    address2: 'Suite 456',
    zip: '94105',
    country: 'United States',
    subscriptionPlan: {
      name: 'Premium',
      status: 'active',
      startDate: '2024-01-01',
      nextBillingDate: '2024-02-01',
    },
    dns: ['192.168.1.1', '192.168.1.2', '192.168.1.3', '192.168.1.4'],
  },
  {
    id: 'USR123457',
    firstName: 'Emma',
    lastName: 'Johnson',
    email: 'emma.johnson@example.com',
    address1: '456 Innovation Ave',
    address2: 'Unit 789',
    zip: '94106',
    country: 'United States',
    subscriptionPlan: {
      name: 'Basic',
      status: 'active',
      startDate: '2024-01-05',
      nextBillingDate: '2024-02-05',
    },
    dns: ['192.168.1.1', '192.168.1.2', '192.168.1.3', '192.168.1.4'],
  },
  {
    id: 'USR123458',
    firstName: 'Michael',
    lastName: 'Brown',
    email: 'michael.brown@example.com',
    address1: '789 Digital Lane',
    address2: null,
    zip: '94107',
    country: 'United States',
    subscriptionPlan: {
      name: 'Premium',
      status: 'active',
      startDate: '2024-01-10',
      nextBillingDate: '2024-02-10',
    },
    dns: ['192.168.1.1', '192.168.1.2', '192.168.1.3', '192.168.1.4'],
  },
  {
    id: 'USR123459',
    firstName: 'Sarah',
    lastName: 'Davis',
    email: 'sarah.davis@example.com',
    address1: '321 Code Road',
    address2: 'Floor 3',
    zip: '94108',
    country: 'United States',
    subscriptionPlan: {
      name: 'Enterprise',
      status: 'active',
      startDate: '2024-01-15',
      nextBillingDate: '2024-02-15',
    },
    dns: ['192.168.1.1', '192.168.1.2', '192.168.1.3', '192.168.1.4'],
  },
  {
    id: 'USR123460',
    firstName: 'David',
    lastName: 'Wilson',
    email: 'david.wilson@example.com',
    address1: '654 Developer Street',
    address2: 'Suite 100',
    zip: '94109',
    country: 'United States',
    subscriptionPlan: {
      name: 'Basic',
      status: 'inactive',
      startDate: '2024-01-20',
      nextBillingDate: '2024-02-20',
    },
    dns: ['192.168.1.1', '192.168.1.2', '192.168.1.3', '192.168.1.4'],
  },
  {
    id: 'USR123461',
    firstName: 'Lisa',
    lastName: 'Anderson',
    email: 'lisa.anderson@example.com',
    address1: '987 Cloud Avenue',
    address2: null,
    zip: '94110',
    country: 'United States',
    subscriptionPlan: {
      name: 'Premium',
      status: 'active',
      startDate: '2024-01-25',
      nextBillingDate: '2024-02-25',
    },
    dns: ['192.168.1.1', '192.168.1.2', '192.168.1.3', '192.168.1.4'],
  },
  {
    id: 'USR123462',
    firstName: 'James',
    lastName: 'Taylor',
    email: 'james.taylor@example.com',
    address1: '147 Data Drive',
    address2: 'Unit 200',
    zip: '94111',
    country: 'United States',
    subscriptionPlan: {
      name: 'Enterprise',
      status: 'active',
      startDate: '2024-01-30',
      nextBillingDate: '2024-02-29',
    },
    dns: ['192.168.1.1', '192.168.1.2', '192.168.1.3', '192.168.1.4'],
  },
  {
    id: 'USR123463',
    firstName: 'Emily',
    lastName: 'Martinez',
    email: 'emily.martinez@example.com',
    address1: '258 Algorithm Road',
    address2: 'Floor 5',
    zip: '94112',
    country: 'United States',
    subscriptionPlan: {
      name: 'Basic',
      status: 'active',
      startDate: '2024-02-01',
      nextBillingDate: '2024-03-01',
    },
    dns: ['192.168.1.1', '192.168.1.2', '192.168.1.3', '192.168.1.4'],
  },
  {
    id: 'USR123464',
    firstName: 'Robert',
    lastName: 'Garcia',
    email: 'robert.garcia@example.com',
    address1: '369 Binary Boulevard',
    address2: null,
    zip: '94113',
    country: 'United States',
    subscriptionPlan: {
      name: 'Premium',
      status: 'active',
      startDate: '2024-02-05',
      nextBillingDate: '2024-03-05',
    },
    dns: ['192.168.1.1', '192.168.1.2', '192.168.1.3', '192.168.1.4'],
  },
  {
    id: 'USR123465',
    firstName: 'Maria',
    lastName: 'Rodriguez',
    email: 'maria.rodriguez@example.com',
    address1: '741 Protocol Place',
    address2: 'Suite 300',
    zip: '94114',
    country: 'United States',
    subscriptionPlan: {
      name: 'Enterprise',
      status: 'active',
      startDate: '2024-02-10',
      nextBillingDate: '2024-03-10',
    },
    dns: ['192.168.1.1', '192.168.1.2', '192.168.1.3', '192.168.1.4'],
  },
];

app.use(express.json());
const PORT = 8000;
const SECRET_KEY = 'secret-key';
const REFRESH_SECRET_KEY = 'refresh-secret-key';

const VALID_USERNAME = 'admin';
const VALID_PASSWORD = 'admin1';

let refreshTokens = [];

const generateTokens = (username) => {
  const accessToken = jwt.sign({ username }, SECRET_KEY, { expiresIn: '1h' });
  const refreshToken = jwt.sign({ username }, REFRESH_SECRET_KEY, {
    expiresIn: '7d',
  });
  refreshTokens.push(refreshToken);
  return { accessToken, refreshToken };
};

const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'No token provided' });
  }
  try {
    const user = jwt.verify(token, SECRET_KEY);
    req.user = user;
    next();
  } catch (err) {
    // Token expired, try to refresh
    const refreshToken = req.headers['x-refresh-token'];
    if (!refreshToken) {
      return res.status(401).json({ message: 'Refresh token required' });
    }

    try {
      if (!refreshTokens.includes(refreshToken)) {
        return res.status(403).json({ message: 'Invalid refresh token' });
      }

      const user = jwt.verify(refreshToken, REFRESH_SECRET_KEY);
      const { accessToken, refreshToken: newRefreshToken } = generateTokens(
        user.username
      );

      // Remove old refresh token and add new one
      refreshTokens = refreshTokens.filter((t) => t !== refreshToken);
      refreshTokens.push(newRefreshToken);

      // Send new tokens in response headers
      res.setHeader('x-access-token', accessToken);
      res.setHeader('x-refresh-token', newRefreshToken);

      req.user = user;
      next();
    } catch (refreshErr) {
      return res.status(403).json({ message: 'Invalid refresh token' });
    }
  }
};

app.post('/api/login', (req, res) => {
  const { username, password } = req.body;

  if (username === VALID_USERNAME && password === VALID_PASSWORD) {
    const { accessToken, refreshToken } = generateTokens(username);
    res.json({ accessToken, refreshToken });
  } else {
    res.status(401).json({ message: 'Invalid credentials' });
  }
});

app.get('/api/users', authenticateToken, (req, res) => {
  res.json(users);
});

app.get('/api/user-details/:userId', authenticateToken, (req, res) => {
  const userId = req.params.userId;
  const userDetails = users.find((user) => user.id === userId);
  if (!userId) {
    return res.status(400).json({ message: 'User ID is required' });
  }
  res.json(userDetails);
});

app.put('/api/users/:userId', authenticateToken, (req, res) => {
  const userId = req.params.userId;
  const updatedUserData = req.body;

  const userIndex = users.findIndex((user) => user.id === userId);

  if (userIndex === -1) {
    return res.status(404).json({ message: 'User not found' });
  }

  users[userIndex] = {
    ...users[userIndex],
    ...updatedUserData,
    id: userId,
  };

  res.json(users[userIndex]);
});

app.post('/api/logout', authenticateToken, (req, res) => {
  const refreshToken = req.headers['x-refresh-token'];
  refreshTokens = refreshTokens.filter((token) => token !== refreshToken);
  res.status(200).json({ message: 'Logged out successfully' });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});

/**
Request mechanism
curl -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"admin"}' http://localhost:8000/api/login
curl -H "Authorization: Bearer ACCESS_TOKEN" -H "x-refresh-token: REFRESH_TOKEN" http://localhost:8000/api/user-details
 */
