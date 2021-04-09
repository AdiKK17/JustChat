const mongoose = require("mongoose");

const chatroomSchema = new mongoose.Schema({
  messages: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Message",
    },
  ],
  users: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
},
{timestamps: true}
);

module.exports = mongoose.model("Chatroom", chatroomSchema);
