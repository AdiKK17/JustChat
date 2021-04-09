const express = require("express");

const { body } = require("express-validator");

const User = require("../models/user");
const userController = require("../controllers/user.controller");

const router = express.Router();

//POST /user/signup
router.post("/signup",
    [
    body("email")
    .trim()
    .isEmail()
    .withMessage("please enter a valid email")
    .custom((value,{req}) => {
        return User.findOne({phoneNumber: value}).then(userDoc => {
            if(userDoc){
                return Promise.reject("Email already exists!");
            }
        });
    }),

    body("password").trim().isLength({min: 6}),
    body("name").trim().not().isEmpty()
],
userController.userSignup);

//GET /user/fetchUsers
router.get("/fetchUsers",userController.fetchUsers);

module.exports = router;