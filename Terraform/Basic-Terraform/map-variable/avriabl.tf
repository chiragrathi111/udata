variable users {
    type = map
    default = {
        chirag = 30
        raja = 28
    }
}

output datas {
    value = "Chirag age is ${lookup(var.users,"chirag")}"
}