const Message = require("./models/message");
const ChatRoom = require("./models/chatroom");
const User = require("./models/user");

const CryptoJS = require("crypto-js");
const { group } = require("console");
// const { use } = require("./routes/user.route");

const socketEvents = (io) => {
  io.of("/").on("connection", async (socket) => {
    console.log("socket just go connected");
    socket.join(socket.handshake.query.userId);

    const user = await User.findById(socket.handshake.query.userId)
      .select("-password -__v")
      .populate({ path: "temp_connections", select: "name email uid" })
      .populate({
        path: "temp_chatrooms",
        select: "users is_group room_name",
        populate: [{ path: "users", select: "name email uid" }],
      })
      .populate({ path: "messages" });

    console.log(user);

    if (user.last_seen == null) {
      console.log("A new user");
    } else {
      console.log("not a new user");
    }

    //sending users to the client
    socket.emit("get_users", { users: user.temp_connections });
    //sending chatrooms to the client
    socket.emit("get_chatrooms", { chatrooms: user.temp_chatrooms });
    //sending new messages that were sent to the user when the user was not connected
    socket.emit("get_messages", { messages: user.messages });

    socket.on("findandadduser", async (data, callback) => {
      const enduser = await User.findOne({ uid: data.uid });
      if (!enduser) {
        callback("done");
        return;
      }
      io.to(enduser.id).emit("new_user", {
        name: user.name,
        email: user.email,
        _id: user._id,
        uid: user.uid,
      });
      io.to(user.id).emit("new_user", {
        name: enduser.name,
        email: enduser.email,
        _id: enduser._id,
        uid: enduser.uid,
      });

      let room = await ChatRoom.create({
        users: [user.id, enduser.id],
      });

      room = await ChatRoom.populate(room, {
        path: "users",
        select: "name email uid",
      });

      io.to(enduser.id).emit("new_chatroom", {
        room: room,
        // name: user.email,
      });
      io.to(user.id).emit("new_chatroom", {
        room: room,
        // name: enduser.email,
      });

      callback({
        name: enduser.name,
        email: enduser.email,
        uid: enduser.uid,
      });

      enduser.temp_chatrooms.push(room);
      enduser.chatrooms.push(room);
      enduser.connections.push(user);
      enduser.temp_connections.push(user);
      await enduser.save();
      user.temp_chatrooms.push(room);
      user.chatrooms.push(room);
      user.connections.push(enduser);
      user.temp_connections.push(enduser);
      await user.save();
    });

    socket.on("creategrouproom", async (data, callback) => {
      let users = data.users;
      users.push(socket.handshake.query.userId);

      let room = await ChatRoom.create({
        users: users,
        room_name: data.name,
        is_group: true,
      });
      room = await ChatRoom.populate(room, {
        path: "users",
        select: "name email uid",
      });
      console.log(room);

      users.forEach(async (u) => {
        io.to(u).emit("new_chatroom", {
          room: room,
        });

        await User.updateOne(
          { _id: u },
          {
            $push: { temp_chatrooms: room, chatrooms: room },
          }
        );
      });
      callback("done");
    });

    // Listen for chatMessage
    socket.on("message", async (data, callback) => {
      //roomId,body,type
      const msg = await Message.create({
        body: data.body,
        room: data.roomId,
        type: data.type,
        fromId: socket.handshake.query.userId,
      });
      console.log(msg);

      socket.to(msg.fromId).emit("new_message", {
        message: msg,
      });
      callback({ body: msg.body, id: msg.id });

      const room = await ChatRoom.findById(msg.room)
        .select("messages users")
        .populate({ path: "users", select: "messages" });
      console.log(room);

      room.users.forEach(async (u) => {
        if (u.id != msg.fromId) {
          io.to(u.id).emit("new_message", {
            message: msg,
          });
          u.messages.push(msg);
          await u.save();
        }
      });

      room.messages.push(msg);
      await room.save();
    });

    socket.on("disconnect", async (data) => {
      console.log("left-------");
      socket.leave(data.room_id);
      user.last_seen = Date.now();
      user.messages = [];
      user.temp_chatrooms = [];
      user.temp_connections = [];
      await user.save();
    });
  });
};

const init = (app) => {
  const server = require("http").createServer(app);
  const io = require("socket.io")(server, { serveClient: false });
  io.set("transports", ["websocket"]);
  socketEvents(io);
  return server;
};

module.exports = init;
