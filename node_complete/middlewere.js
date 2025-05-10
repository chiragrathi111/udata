const express = require("express")
const app = express()
const route = express.Router()

const reqFilter = (req,res,next)=>{ //This method called middlewere
    if(!req.query.age){
        res.send("Age is required please enter a age")
    }else if(req.query.age<18){
        res.send("you are not eligible because your age is less then 18")
    }else{
        next(); //is key ka use karne se page fine work ke saath other page mai move bhi karta ai
    }
}
route.use(reqFilter) //this two line use multilple places routing created
// This line use multiple route proper working


// app.use(reqFilter)   //this line called middlewere //This line called application level middlewere
//kisi specific route mai middlewere lagana hai to uske get methed mai lagate hai

// app.get('',reqFilter,(req,res)=>{  //reqFilter jis route mai lagaya jata hai ye usi le liye work karta hai
//     res.send("Welcome Home page")
// })
app.get('/',(req,res)=>{
    res.send("Welcome Home page")
});

app.get('/about',(req,res)=>{
    res.send("Welcome About page")
});

route.get('/user',(req,res)=>{
    res.send("Welcome User page")
});

route.get('/contact',(req,res)=>{
    res.send("Welcome Contact page")
})

app.use('/',route); //This line use route and app connect

app.listen(5000);

///////////////////////////////////////////////////////////////////////////////