// const {Client} = require('pg')

// const client = new Client({
//     host: "localhost",
//     user: "postgres",
//     port: 5432,
//     password: "postgres",
//     database: "postgres"
// })

// client.connect();

// client.query(`select * from student`,(err,res)=>{
//     if(!err){
//         console.log(res.rows);
//     }else{
//         console.log(err.message);
//     }

// client.end;    
// })


const {Client} = require('pg')

const data = {
    Name: "kanha",
    age: 21,
    id: 104,
    email: "kanha@gmail.com"
}
const client = new Client({
    host: "localhost",
    user: "postgres",
    port: 5432,
    password: "postgres",
    database: "postgres"
})

client.connect();

client.query(`insert into student values (${data});`,(err,res)=>{
    if(!err){
        console.log(res.rows);
    }else{
        console.log(err.message);
    }

client.end;    
});