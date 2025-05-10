//

// class Railway{
//      submit = ()=>{
//         console.log(this.name,"Submit successfully")
//     }
//     cancel() {
//         console.log(this.name,"From cancel")
//         // class ke under function ko seethe put kar dete hai
//     }
//     fill(name){
//         this.name = name
//     }
// }

// let chirag = new Railway();
// let raja = new Railway();
// chirag.fill("chiragg")
// raja.fill("raja")
// chirag.submit()
// raja.submit()
// raja.cancel()

// class and oblect using constructor

class student{

    constructor(name,age,address){
    this.name=student.capital(name)
    // this._name=student.capital(name) // This line is using get method
    this.age=age
    this.address=address
    }

    submit(){
        console.log(`${this.name} registration is Successfully and your age is : ${this.age} \n your address is : ${this.address} `);
    
    }
    cancel(){
        console.log(`${this.name} registration is Failed`);
    }
    static capital(name){
        return name.charAt(0).toUpperCase() + name.substr(1,name.length)
    }
    get newNameh(){
        return this._name //get method ka use constructor ke name ko direct console.log ke through print karane ke liye hota hai.
    }
}
const chirag = new student("chirag rathi",28,"Tarighat");
const raja = new student("raja Tawri",26,"Patan");
const kishan = new student("kishan rathi",23,"Parsulidih");

chirag.submit()
console.log(chirag.newNameh)//This line show error
raja.cancel()
raja.submit()
kishan.cancel();

//Inheritance

// class Animal{
//     constructor(color,sound){
//         this.color=color
//         this.sound=sound
//         console.log("I am a parent")
//     }
//     colors(){
//         console.log(`The ${this.color} is animal`)
//     }
//     sounds(){
//         console.log(`The ${this.sound} is very good`)
//     }
// }
// class Dog extends Animal{
//     bark(){
//     console.log("Dog barking is bhow bhow")
//     }
//     // sounds(){
//     //     console.log(`sounds is changed ${this.sound}`)
//     //     // method overring is possible
//     // }
//     sounds(){
//         super.sounds("meow")
//         //If consturctor ka method hoga to hamesha obj. banate time hi con. value provide karna  padta hai and isme super method work hi nahi karta hai
//     }
// } 
// const a = new Animal("blue","slow")
// const d = new Dog("black","bhow")// Parent class ke construtor ko direct use kar sakta hai

// a.colors()
// a.sounds()
// // a.bark() //parent class child class ke method ko call nahi kar sakta hai
// d.colors()
// d.bark()
// d.sounds()

