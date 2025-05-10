//

const express = require('express')
const app = express()
const port = 3000

app.get('/',(req,res)=>{
    console.log(req.query)
    res.send("HEllo Chirag")
})
app.listen(port,()=>{
    console.log(`The example post http://localhost:${port}`)
})