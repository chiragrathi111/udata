// const data = {
//     userId: 2,
//     title: "chirag",
//     body: "Tarighat"
// };
// let options = {
//     method: "POST",
//     body: JSON.stringify(data),
//     headers: {
//         'Content-Type': "application/json"
//     }
// };
// fetch("https://jsonplaceholder.typicode.com/posts/",options)
//     .then((val1)=>{
//         console.log(val1.status)
//         return val1.text()
//     }).then((val2)=>{
//         console.log(val2)
//     }).catch((err)=>{
//         console.log(err)
//     });


////

const data = {
    userId: 1,
    title: "chirag rathi",
    body: "He is From Chhattishgarh"
};
const options = {
    method: "POST",
    body: JSON.stringify(data),
    headers: {
        "Content-type": "application/json"
    }
};
const func = async ()=>{
    let p = await fetch("https://jsonplaceholder.typicode.com/posts/",options)
    // let responce = await p.json()
    // return responce
    return p.json()
}
const getData = async ()=>{
    let g = await fetch("https://jsonplaceholder.typicode.com/todos/1")
    return g.json()
}
const resp = async ()=>{
    let ress = await func()
    console.log(ress)
    console.log(await getData()) // show get data code
    // If second function create karke use async and await nahi karaya to hame Promise pendding return hoga na ki response
}
resp();
// console.log(func()) //not working show Promise is pendding
