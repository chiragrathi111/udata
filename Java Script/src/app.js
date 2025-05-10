const express = require("express");
const app = express();
require("./conn/conn");
const Student = require("./modal/modal");   
const port = process.env.PORT || 3000;

// app.get("/",(req,res)=>{
//     res.send("hello world...")
// })

app.post("/students",(req,res)=>{
    res.send("hello from the other side");
})

app.listen(port,()=>{
    console.log(`The connection is setup ${port}`);
})

