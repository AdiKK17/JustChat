const Message = require("./models/message");
const ChatRoom = require("./models/chatroom");
const User = require("./models/user");

const CryptoJS = require("crypto-js");

const socketEvents = (io) => {
  io.of("/").on("connection", async (socket) => {
    
    console.log("socket just go connected");
    // console.log(socket.id);
    // console.log(socket.handshake.query);
    // console.log(socket.handshake.query.name);
    // console.log(Date.now().toString());
    socket.join(socket.handshake.query.userId);
    const user = await User.findById(socket.handshake.query.userId)
      .select("last_seen name email chatRooms messages")
      .populate("messages chatRooms.room");
    // .select(["last_seen", "name", "email", "chatRooms"])
    // .populate("chatRooms.room");
    console.log(user.messages);
    let users;
    let chatrooms = [];

    if (user.last_seen == null) {
      console.log("A new user");
      users = await User.find().select("email name");
      //  console.log(users);

      //sending new user to rest of the connected clients
      socket.broadcast.emit("receive_new_user", { user: user });
    } else {
      console.log("not a new user");
      user.chatRooms.forEach((element) => {
        if (element.createdAt > user.last_seen) {
          chatrooms.push(element);
        }
      });
      users = await User.find({ createdAt: { $gt: user.last_seen } }).select(
        "email name"
      );
      // console.log(users);
    }

    //sending chatrooms to the client
    socket.emit("get_chatRooms", { chatrooms: chatrooms });
    //sending users to the client
    socket.emit("receive_users", { users: users });
    //sending new messages that were to the user when the user was not connected
    socket.emit("unreceived_messages", { messages: user.messages });

    socket.on("createRoom", async (data, callback) => {
      let users = [];
      users.push(socket.handshake.query.userId);
      users.push(data.user);
      const room = await ChatRoom.create({
        users: users,
      });
      console.log(room);
      socket.emit("new_chatroom", {
        room: room,
        name: data.name,
        userId: data.user,
      });
      socket
        .to(data.user)
        .emit("new_chatroom", {
          room: room,
          name: user.name,
          userId: user._id,
        });
      callback("done");

      const otherUser = await User.findById(data.user).select("chatRooms");

      user.chatRooms.push({ room: room, name: data.name, userId: data.user });
      user.save();
      otherUser.chatRooms.push({
        room: room,
        name: user.name,
        userId: user._id,
      });
      otherUser.save();
    });

    socket.on("createGroupRoom", async (data, callback) => {
      let users = [];
      users.push(socket.handshake.query.userId);
      data.user.forEach((u) => {
        users.push(u);
      });

      const room = await ChatRoom.create({
        users: users,
      });
      console.log(room);

      socket.emit("new_chatroom", { room: room, name: data.name });
      data.user.forEach((u) => {
        socket.to(u).emit("new_chatroom", { room: room, name: data.name });
      });

      callback("done");

      user.chatRooms.push({ room: room, name: data.name });
      user.save();

      data.user.forEach(async (u) => {
        const otherUser = await User.findById(u).select("chatRooms");
        otherUser.chatRooms.push({ room: room, name: user.name });
        otherUser.save();
      });
    });

    //joining chatrooms
    socket.on("joining_my_rooms", async (data, callback) => {
      //  console.log(data);
      console.log("joining rooms called");
      data.rooms.forEach((e) => {
        socket.join(e);
      });
    });

    // Listen for chatMessage
    socket.on("chat_message", async (data, callback) => {
      socket
        .to(data.roomId)
        .emit("message", {
          data: data,
          fromId: socket.handshake.query.userId,
          fromName: socket.handshake.query.name,
        });

      callback(data.body);

      const msg = await Message.create({
        body: data.body,
        room: data.roomId,
        fromId: socket.handshake.query.userId,
        fromName: socket.handshake.query.name,
      });

      const room = await ChatRoom.findById(data.roomId)
        .select("messages users")
        .populate({ path: "users", select: "messages" });
      console.log(room.users);

      room.users.forEach((u) => {
        if (u.id != socket.handshake.query.userId) {
          u.messages.push(msg);
          u.save();
        }
      });

      room.messages.push(msg);
      room.save();
    });

    socket.on("disconnect", async (data) => {
      const user = await User.findById(socket.handshake.query.userId);
      console.log("left-------");
      user.last_seen = Date.now();
      user.messages = [];
      user.save();
      // socket.leave(data.room_id);
    });
  });
};

const init = (app) => {
  const server = require("http").createServer(app);
  const io = require("socket.io")(server, { serveClient: false });
  //io.set("transports", ["websocket"]);
  socketEvents(io);
  return server;
};

module.exports = init;
