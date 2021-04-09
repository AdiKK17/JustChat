const mongoose = require("mongoose");

const messageSchema = new mongoose.Schema({
  body: {
    type: String,
    required: "message body is required",
  },
  room: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Chatroom",
  },
  //for 1st method
  // to: [{
    // type: mongoose.Schema.Types.ObjectId,
    // ref: "User",
  // }],
  fromId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: "sender user should not be empty",
  },
  fromName: {
    type: String,
  },
  time: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model("Message", messageSchema);
