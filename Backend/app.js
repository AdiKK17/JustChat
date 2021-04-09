const express = require("express");
const bodyParser = require('body-parser');
const mongoose = require("mongoose");

const userAuthRoutes = require("./routes/user.route");

const socketio = require("./socketio");
const app = express();
const server = socketio(app);

app.use(bodyParser.json({limit: '5mb'})); // application/json
app.use(bodyParser.urlencoded({ extended: true, limit: "5mb" }));

app.use((req, res, next) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader(
      'Access-Control-Allow-Methods',
      'OPTIONS, GET, POST, PUT, PATCH, DELETE'
    );
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    next();
  });


mongoose
.connect(process.env.MONGO_URL,{useUnifiedTopology: true, useNewUrlParser: true, useFindAndModify: false })
.then((db) => {
  if (db == null) {
    throw new Error("Error connecting to DB");
  }
  console.log("DB Connected");
})
.catch((err) => {
  console.error(err.message);
});


app.get('/', (req, res) => {
  res.send("Node Server is running. Yay!!")
});

app.use("/user",userAuthRoutes);

app.use((error, req, res, next) => {
  console.log(error);
  console.log("!!!!!!!!!");
  const status = error.statusCode || 500;
  const message = error.message; 
  const data = error.data;
  res.status(status).json({error: message,data: data});
});

server.listen(process.env.PORT || 3000);
































































