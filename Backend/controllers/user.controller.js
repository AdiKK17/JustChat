const User = require("../models/user");

const bcrypt = require("bcryptjs");

const { validationResult } = require("express-validator");

exports.userSignup = async (req, res, next) => {
  try {
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
      const error = new Error("Validation failed.");
      error.statusCode = 422;
      error.data = errors.array();
      throw error;
    }

    const { email, name, password } = req.body;

    let hashedPw = await bcrypt.hash(password, 8);
    const user = await User.create({
      email: email,
      password: hashedPw,
      name: name,
    });

    res.status(201).json({ message: "Succesfully signed up", result: user });
  } catch (err) {
    if (!err.statusCode) {
      err.statusCode = 500;
    }
    next(err);
  }
};

exports.getUser = async (req, res, next) => {
  try {
    const users = await User.findById(req.body.userId);

    res.status(200).json({ result: user });
  } catch (err) {
    if (!err.statusCode) {
      err.statusCode = 500;
    }
    next(err);
  }
};

exports.fetchUsers = async (req, res, next) => {
  try {
    const users = await User.find().select("email name");

    res.status(200).json({ result: users });
  } catch (err) {
    if (!err.statusCode) {
      err.statusCode = 500;
    }
    next(err);
  }
};
