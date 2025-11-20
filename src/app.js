const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const todoRoutes = require('./routes/todo.routes');

const app = express();
const PORT = 3000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://mongo:27017/todos';

app.use(cors());
app.use(express.json());

mongoose.connect(MONGO_URI)
    .then(() => console.log('Connected to MongoDB'))
    .catch(err => console.error('Could not connect to MongoDB', err));

app.use('/todos', todoRoutes);

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});