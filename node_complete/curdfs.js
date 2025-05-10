// const fs = require('fs')
// const path = require('path')
// const dir_path= path.join(__dirname,'curd')
// const filePath = `${dir_path}/file.js`

// fs.writeFileSync(filePath,'this is curd file for scratch')  //create a file

// fs.readFile(filePath,'utf-8',(err,file)=>{  //read karne ke liye utf-8 ka use kiya jata hai ye string type ka hota hai
//     console.log(file)  //this line show buffer format data without utf-8 using
// })

// fs.appendFile(filePath,'\n append data for new line',(err)=>{
//   if(!err)
//     console.log('file is appended')
// })

// fs.unlinkSync(filePath) //remove the file

const color = require("colors")
const express = require('express')

const app = express()

app.get('',(req,res)=>{
    console.log(color.blue("Name",req.query.name)) //browser mai jo dalte hai wahi data aata hai
    res.send(`This is home page, ${req.query.name}`)
    
})
app.get('/about',(req,res)=>{
    res.send('Hello , This is a About page')
    // const user={
    //     name:'chirag',
    //     email:'chirag@gmail.com',
    //     hobby:'chess'
    // }
    // res.render({user})
})
app.get('*',(req,res)=>{
    res.send('This is invalid page 404')
    console.log('this is invalid page'.red)  //colour ka use console mai hi kiya jata hai   
})
app.listen(4500);
