// console.log(__dirname);
// console.log(__filename);
// # create a server basic:-

// const http = require('http');

// http.createServer((req,res)=>{    //first mai req and after res hota hai and http ko install karna bhi jaruri hota hai
//     res.write("my name is chirag")
//     res.end();
// }).listen(4500);


// const http = require("http");
// const data = require("./modal")

// http.createServer((req,res)=>{
//     res.writeHead(200,{'Content-Type':'application\json'});
//     res.write(JSON.stringify(data))
//     res.end()
// }).listen(4500);

// console.log(process.argv[1])  //iska use extra comment node ke saath run karne ke liye kar sakte hai

// const fs = require("fs")
// fs.writeFileSync('abx.js',"chirag")  //this two line command use create any file with content


// const fs = require("fs")
// const path = require("path")

// const dir_path = path.join(__dirname,folder_name)

// for(let i = 0;i<10;i++){
//     fs.writeFileSync(dir_path+`node${i}.js`,'hello') //use directory ke ander file create ho jata hai
// }  //create a multiple file

// const fs = require("fs")
// for(let i=0;i<10;i++){
//     fs.unlinkSync(`node${i}.js`)
// }  //htis code using multiple line are remove

const fs = require("fs")
const path = require("path")
const dir_path = path.join(__dirname,'folder_name')

// for(let i = 0;i<10;i++){
//     fs.writeFileSync(dir_path+`node${i}.js`,'hello') //use directory ke ander file create ho jata hai
// }









