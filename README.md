# shuttlemaster

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Backend Setup (Node.js)

1. Rename .env.example to .env and add your Stripe secret key inside the .env file.
2. Install dependencies by running the following commands in the terminal:
   - cd backend
   - npm install
   - npm install dotenv
3. Run this command to start the server:
   - node index.js
4. After running node index.js, you should see a message like:
   - Server running on http://localhost:3000
5. Once the server is running, you can begin using the backend API.

*Note for beginners*: If you don't have Node.js installed, please download and install it from [Node.js official website](https://nodejs.org/). You can verify your installation with the command node -v.

## Frontend Flutter Setup

1. Install Flutter dependencies by running:
   - flutter pub get
2. Run the app with:
   - flutter run