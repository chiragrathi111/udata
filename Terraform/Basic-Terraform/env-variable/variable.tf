variable user {
    type = string
}

output usernames {
    value = "Hello, ${var.user}"
}

#If I want use environment variable for our file according this is possible
#First enter env varible use some prefix value then value automatic use
#export TF_VAR_user=Chirag
#basically export user=chirag but automatic using in terraform 
#so TF_VAR define need otherwise not work
#If you enter space between name so only show before space value