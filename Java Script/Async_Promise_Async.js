//

// let a = confirm("are you confirm");
// if(a){
//     console.log("yes")
// }
// else{
//     console.log("no")
// }

//Asynchronous
// console.log("start")
// setTimeout(function(){
//     console.log("iam good");

// },3000)
// console.log("end")

// Synchronous method is one line or methed execute then after go second line or second method 

// promise

// let promise = new Promise((resolve,reject)=>{
//     console.log("promise is pendding")
//     setTimeout(()=>{
//         console.log("running")

//     },5000)
//     // resolve(100)
//     // reject(200)
//     reject(new Error("I am A error")) // Kabhi bhi errro show karane ke liye iska use kiya jata hai jab reslove ka use na karke seedhe rejected ka use karte hai
// })
// console.log("end")
// console.log(promise)

// promise using then and catch

// let p1 = new Promise((resolve,reject)=>{
//     console.log("promise is pending")
//     setTimeout(()=>{
//     },10000)
//         resolve(100)

// })
//     // console.log(p1)


// let p2 = new Promise((resolve,reject)=>{
//     console.log("p2 is pendding")
//     setTimeout(()=>{
//     },5000)
//         reject(new Error("I am a Error"))

// })
//     // console.log(p2)

// p1.then((value)=>{
//     console.log(value)
// })    

// p2.catch((Error)=>{
//     console.log("something is wrong....")
// })

// Chaining Promise

// let p1 = new Promise((resolve,reject)=>{
//     console.log("start")
//     setTimeout(()=>{
//         resolve(100)
//     },5000)
// })

// p1.then((value)=>{
//     console.log(`the value is ${value}`)
//     // isi tarah se multiple Promise laga sakte hai
//     return new Promise((resolve,reject)=>{
//         setTimeout(()=>{
//         resolve("I am a second Promise")

//         },5000)
//     })
// }).then((value)=>{
//     console.log(value)
// }).catch((Error)=>{
//     console.log("something is wrong")
// })

// Async and await

//  async function chirag(){

//         let p1 = new Promise((resolve,reject)=>{
//             setTimeout(()=>{
//                 // console.log("Start...")
//                 resolve(100)
//             },5000)
//         })
//         let p2 = new Promise((resolve,reject)=>{
//             setTimeout(()=>{
//                 // console.log("Start. p2..")
//                 resolve(200)
//             },7000)
//         })
//         console.log("await starting..")
//         let a = await p1
//         console.log("p1 complted",a)
//         console.log("p2 starting")

//         let b = await p2
//         console.log("p2 complete",b)
//         // return(a,b) // a ki value not show
//         return[a,b]
// }
// let rathi =  chirag()
// rathi.then((value)=>{
//     console.log(value)
// })

//  try and catch

// try{
//     console.log(chirag)
// }catch(err){
//     console.log(err.name)
//     console.log(err.message)
//     console.log(err.stack)
// }

//async and await 
// const b = [
//     {name: "chirag",age: 28,hobby: "chess"},
//     {name: "raja  ",age: 26,hobby: "chess"},
//     {name: "kishan",age: 23,hobby: "badminton"},
//     {name: "govind",age: 24,hobby: "card"},
// ]
// function getData(){
//     setTimeout(()=>{
//         let c=""
//         b.forEach((data,index)=>{
//          c += data.name + "  "+data.hobby + "\n"         
//         })
//             console.log(c)
//     },2000)
// }

// function createData(newData){
//     return new Promise((resolve,reject)=>{

//         setTimeout(()=>{
//             b.push(newData)
//             let error = false
//             if(!error){
//                 resolve()
//             }else{
//                 reject("somthing error")
//             }
//         },5000)
//     })
// }

// async function startt(){
//     await createData({name: "kanha ",age: 19,hobby: "cricket"})
//     getData()
// }
// startt()

//

// var url1 = "https://dummy.restapiexample.com/api/v1/employees"
// var f = fetch(url1)
// f.then(r=>{
// 	r.json()
// 	}).then(q=>{
// 		console.log(q)})









