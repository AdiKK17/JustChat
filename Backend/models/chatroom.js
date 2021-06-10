const mongoose = require("mongoose");

const chatroomSchema = new mongoose.Schema(
  {
    room_name: {
      type: String,
      default: "none",
    },
    messages: [{ type: mongoose.Schema.Types.ObjectId, ref: "Message" }],
    users: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
    is_group: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Chatroom", chatroomSchema);
