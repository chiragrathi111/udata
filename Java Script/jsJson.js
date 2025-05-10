let user = '{"employees":['+
    '{"name":"Chirag Rathi", "age":28},'+
    '{"name":"Raja Tawri  ", "age":26},'+
    '{"name":"Govind Tawri", "age":24},'+
    '{"name":"Kishan Rathi", "age":23}]}';
console.log(user)
console.log(typeof user)
const values = JSON.parse(user)//This line show is proper JSON format
console.log(values)    
console.log(typeof values)
// console.log(values.employees[0].name)
// console.log(values.employees.length)
// console.log(values.employees.sort())
// //Array ko print karne ke liye hamesha [] ka use kiya jata hai jabki kisi bhi object ko print karane ke liye .keyvalue karne se value mil jata hai
// console.log(`The Employee Name is: ${values.employees[0].name} \nThe Employee Age is : ${values.employees[0].age} `)
// // console.log(user) //This line also print value but looking wise not good, Show in Object format

// let a = [1,9,8,6,3,10,59,7,100,2]
// let a = ["chi","rat","kis","gov","yansh","dolly"]
// console.log(a.sort())
// sort method properly use in alphabatical format not a integer format 