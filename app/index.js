const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const APP_NAME = process.env.APP_NAME || "TodoApp";

app.use(express.json());

let todos = [];

app.get('/', (req, res) => {
  res.send(`Welcome to ${APP_NAME}`);
});

app.get('/todos', (req, res) => {
  res.json(todos);
});

app.post('/todos', (req, res) => {
  const todo = req.body;
  todos.push(todo);
  res.status(201).json(todo);
});

app.listen(PORT, () => {
  console.log(`${APP_NAME} running on port ${PORT}`);
});
