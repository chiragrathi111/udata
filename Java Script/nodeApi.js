//get method old not using direct link

// const http = require('http');

// const options = {
//     hostname: 'jsonplaceholder.typicode.com',
//     path: '/posts/1',
//     method: 'GET',
//     headers: {
//         'Content-Type': 'application/json',
//     },
// };

// const getPosts = ()=>{
//     let data = ''

//     const request = http.request(options,(response)=>{
//         response.setEncoding('utf8');

//         response.on('data',(chunk)=>{
//             data += chunk
//         });

//         response.on('end',()=>{
//             console.log(data);
//         });
//     });

//     request.on('error',(error)=>{
//         console.log(error)
//     });

//     request.end();
// };

// getPosts();

//get method new using direct link

// const http = require('http');

// const getPosts = ()=>{

//     let data=''

//     const request = http.get('http://jsonplaceholder.typicode.com/posts/2',(Response)=>{

//     Response.setEncoding('utf8');

//     Response.on('data',(chunk)=>{
//         data += chunk
//     });

//     Response.on('end',()=>{
//         console.log(data)
//     });
//     });

//     request.on('error',(err)=>{
//         console.log(err)
//     });

//     request.end();
// };
// getPosts();

////Post method

// const http = require('http');

// const postData = JSON.stringify({
//     title: 'chirag',
//     body: 'rathi',
//     userId: 1,
// });

// const options = {
//     hostname: 'jsonplaceholder.typicode.com',
//     path: '/posts',
//     method: 'POST',
//     headers: {
//         'Content-Type': 'application/json',
//         'Content-Length': Buffer.byteLength(postData),
//     },
// };

// const makePost = ()=>{
//     let data = ''

//     const request = http.request(options,(Response)=>{
//         Response.setEncoding('utf8')
//         Response.on('data',(chunk)=>{
//             data += chunk
//         });
//         Response.on('end',()=>{
//             console.log(data)
//         });
//     });
//     request.on('error',(err)=>{
//         console.log(err)
//     });

//     request.write(postData);
//     request.end()
// };
// makePost();
// const fetch = require('node-fetch');
// const getPost = (num) => {
//     fetch(`https://jsonplaceholder.typicode.com/posts/${num}`)
//       .then(response => response.json())
//       .then(data => console.log(data))
//       .catch((err)=>{
//         console.log('something went wrong')
//       });
//   };
  
//   getPost(1);

//

// above line is not working so update package.json file and add this new line
// "type":"module"
// import fetch from 'node-fetch';
// const fetch = require("node-fetch");

let a = fetch("https://jsonplaceholder.typicode.com/posts/");
    a.then((res)=>{
        console.log('success')
        return res.json()
    }).then((res2)=>{
        console.log('test')
        console.log(res2)
    }).catch((err)=>{
        console.log("some went wrong")
    })


