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
  type: {
    type: String,
    default: "text", // text,audio,video,image
  },
  fromId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: "sender user should not be empty",
  },
  time: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model("Message", messageSchema);
