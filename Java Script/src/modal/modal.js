const mongoose = require("mongoose");
const validator = require("validator");

const studentSchema = new mongoose.Schema({
    name: {
        type:String,
        required:true,
        minlength:3
    },
    email: {
        type:String,
        required:true,
        unique:[true,"Email is already valid"], //Sequre breket ka use karke check valid and invalid
        validate(value){
            if(!validator.isEmail(value)){
                throw new Error("Invalid Email")
            }
        } 
    },
    mobile: {
        type:Number,
        required:true,
        min:10,
        max:10,
        unique:true
    },
    address: {
        type:String,
        required:true
    }
})

const Student = new mongoose.Model('Student',studentSchema);

module.exports = Student;