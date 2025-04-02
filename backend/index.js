const express = require('express');
const bodyParser = require('body-parser');
require('dotenv').config(); // Load environment variables from .env file

const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY); // Access the secret key from the .env file

const app = express();
app.use(bodyParser.json());

// API endpoint to create a payment intent
app.post('/create-payment-intent', async (req, res) => {
  try {
    const { amount } = req.body; 

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: 'usd',  
    });

    res.status(200).send({ clientSecret: paymentIntent.client_secret });
  } catch (error) {
    res.status(500).send({ error: error.message });
  }
});

// Start the server on port 3000
const port = 3000;
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});