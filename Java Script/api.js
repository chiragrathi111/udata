// get method 1

// fetch("https://jsonplaceholder.typicode.com/posts/").then((value)=>{
//     console.log(value.status)
//     console.log(value.ok)
// //     console.log(value)// Showing not understand Data
//     return value.json() //return is most important otherwise final value show undefind
// }).then((value2)=>{
//     console.log(value2)
// }).catch((err)=>{
//       console.log("something went wrong")
// })

//get method 2

// let a = fetch("https://jsonplaceholder.typicode.com/todos/");
//     a.then((res)=>{
//         console.log('success')
//         return res.json()
//     }).then((res2)=>{
//         console.log('test')
//         console.log(res2)
//     }).catch((err)=>{
//         console.log("some went wrong")
//     })

//post method

const data = {
      userId: 1,
      title: "chirag rathi",
      body: "chirag is good boy"
};

fetch("https://jsonplaceholder.typicode.com/posts/",{
      method: 'POST',
      body: JSON.stringify(data),
      headers: {
            'Content-Type': 'application/json'
      },
}).then((val1)=>{
      return val1.json()
}).then((val2)=>{
      console.log(val2)
}).catch((err)=>{
      console.log(err)
});

