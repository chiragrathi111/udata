const threeDot = ((a,b,c)=>{
   console.log(a*b*c) ;
})

let numbers = [10,20,50];
threeDot(...numbers);
let b= [...numbers];
console.log(b)
let c = {...numbers}
console.log(c)

//Conclusion ... ka use karke array ke value ko new array mai or new object mai create kar sakte hai.
  