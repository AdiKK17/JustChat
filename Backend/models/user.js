const mongoose = require("mongoose");
// const { messageSchema } = require("./message");

const userSchema = new mongoose.Schema(
  {
    uid: {
      type: String,
      required: true,
      unique: true,
    },
    name: {
      type: String,
      // required: true,
    },
    email: {
      type: String,
      required: true,
    },
    password: {
      type: String,
      required: true,
    },
    last_seen: {
      type: Date,
      default: null,
    },
    temp_chatrooms: [{ type: mongoose.Schema.Types.ObjectId, ref: "Chatroom" }],
    chatrooms: [
      // {
      //   _id: false,
      //   room: { type: mongoose.Schema.Types.ObjectId, ref: "Chatroom" },
      //   name: { type: String },
      //   userId: { type: String, default: null },
      //   createdAt: { type: Date, default: Date.now },
      // },
      { type: mongoose.Schema.Types.ObjectId, ref: "Chatroom" },
    ],
    temp_connections: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
    connections: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
    // this list will only have the messages that are received
    messages: [{ type: mongoose.Schema.Types.ObjectId, ref: "Message" }],
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", userSchema);
