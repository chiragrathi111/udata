variable users {
    type = list
}

output username {
    value = "First user is ${var.users[0]}"
}

#["Chirag","Ram","Shyam"]
#if your type is list then user variable this type 
#enter this list value we are using enter multiple Security Group
#terraform plan -var 'users=["Chirag","Ram","Shyam"]'
# IF i want all list value print so added output value
# value = "${join(",",var.users)}"