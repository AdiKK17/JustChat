const mongoose = require("mongoose");
const { Timestamp } = require("mongodb");

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  email: {
    type: String,
    required: true
  },
  password: {
      type: String,
    required: true
  },
  last_seen: {
      type: Date,
      default: null
  },
  chatRooms: [{
    _id: false,
    room: {type: mongoose.Schema.Types.ObjectId,ref: "Chatroom"},
    name: {type: String},
    userId: {type: String,default: null},
    createdAt: {type: Date,default: Date.now}
  }],
  // this list will only have the messages that are received
  messages: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Message",
    },
  ],
},
{timestamps: true}
);

module.exports = mongoose.model("User", userSchema);
