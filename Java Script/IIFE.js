//

// let a = ()=>{
//     return new Promise((resolve,reject)=>{
//         setTimeout(()=>{
//             resolve(123)
//         },5000)
//     })
// }
// (async ()=>{
//     let b = await a()
//     console.log(b)
//     let c = await a()
//     console.log(c)
//     let d = await a()
//     console.log(d)
// })()
//async ke starting and ending prentheses se karna and function ko call karne ke bajay empty
//  parentheses ko put karna hi IIFE kahlata hai

//

// const arr = [3,3,9]
// const obj = {...arr}//... ka use karke array ko object mai convert kar diye
// console.log(obj)

// const f = (a,b,c)=>{
//     return a*b*c
// }
// console.log(f(...arr))//... ka use karke function ke variable mai value bhi array ke through put kar diye

// const {d,e,g}  = {d: 10,e: 20,g:30}
// // const {d,e,g} = obj1
// console.log(d,e,g)

const h = {
    name: "chirag",
    age: 28
}
// console.log({h, name: "rathi"})
console.log({...h,name: "rathi"})//kisi bhi obj mai value tabhi change hoga jab uske object mai ... laga ho
