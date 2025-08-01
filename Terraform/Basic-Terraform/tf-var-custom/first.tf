variable firstname {
    type=string
}

variable lastname {
    type=string
}

variable age {
    type=number

}

output datas {
    value = "My name is ${var.firstname} ${var.lastname}, My age is ${var.age}"
}