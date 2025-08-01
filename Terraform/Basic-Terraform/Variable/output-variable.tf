output username {
    value = "Hello, ${var.firstname} ${var.lastname}"
}
#terraform plan -var "firstname=Chirag" -var "lastname=Rathi"
# If i want not ask user because running time facing issue so i direct enter on our command