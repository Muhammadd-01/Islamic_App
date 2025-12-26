# Islamic App Admin Panel

A MERN stack admin panel for managing the Islamic App users and orders.

## Features

- 📊 **Dashboard** - Overview stats, revenue tracking, user/order counts
- 👥 **User Management** - View all users, change roles, delete users
- 📦 **Order Management** - View orders, update status, delete orders
- 🔥 **Firebase Integration** - Real-time sync with Firestore

## Tech Stack

- **Backend**: Node.js, Express.js, Firebase Admin SDK
- **Frontend**: React, Vite, TailwindCSS
- **Database**: Firebase Firestore

## Setup

### Prerequisites

1. Node.js 18+ installed
2. Firebase project with Firestore enabled
3. Service account key from Firebase Console

### 1. Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to Project Settings → Service Accounts
4. Click "Generate New Private Key"
5. Save the JSON file as `server/config/serviceAccountKey.json`

### 2. Install Dependencies

```bash
# From admin-panel directory
npm run install-all
```

Or manually:

```bash
# Install root dependencies
npm install

# Install server dependencies
cd server && npm install

# Install client dependencies
cd ../client && npm install
```

### 3. Configure Environment

```bash
# Copy environment template
cp server/.env.example server/.env

# Edit server/.env with your settings
```

### 4. Run Development Server

```bash
# Run both server and client
npm run dev

# Or run separately:
npm run server  # Backend on http://localhost:5000
npm run client  # Frontend on http://localhost:5173
```

## API Endpoints

### Users
- `GET    /api/users` - Get all users
- `GET    /api/users/:id` - Get single user
- `PATCH  /api/users/:id/role` - Update user role
- `DELETE /api/users/:id` - Delete user

### Orders
- `GET    /api/orders` - Get all orders
- `GET    /api/orders/:id` - Get single order
- `PATCH  /api/orders/:id/status` - Update order status
- `DELETE /api/orders/:id` - Delete order

### Stats
- `GET    /api/stats` - Dashboard statistics
- `GET    /api/stats/orders-chart` - Orders chart data

## Firestore Collections

The admin panel manages these collections:

- `users/` - User profiles
- `carts/` - User shopping carts
- `orders/` - Order history

## License

MIT
