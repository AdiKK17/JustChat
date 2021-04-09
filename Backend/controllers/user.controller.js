const User = require('../models/user');

const bcrypt = require('bcryptjs');

const { validationResult } = require('express-validator');

exports.userSignup = (req, res, next) => {

    const errors = validationResult(req);

    if( !errors.isEmpty()){
        const error = new Error('Validation failed.');
        error.statusCode = 422;
        error.data = errors.array();
        throw error;
    }
        
    const email = req.body.email;
    const name = req.body.name;
    const password = req.body.password.trim();
    
    bcrypt.hash(password, 8)
    .then(hashedPw => {
        const user = new User({
            email: email,
            password: hashedPw,
            name: name
        })
            return user.save();
    })
    .then(user => {
            res.status(201).json({ message: 'Succesfully signed up', result: user });
    })
    .catch(err => {
        if(!err.statusCode) {
            err.statusCode = 500;
        }
        next(err);
    })
}

exports.fetchUsers = async (req, res, next) => {
    try{
    const users = await User.find()
    .select("email name");

    res.status(200).json({result: users});
    }
    catch(err) {
        if(!err.statusCode) {
            err.statusCode = 500;
        }
        next(err);
    }
}







