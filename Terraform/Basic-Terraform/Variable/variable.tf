variable firstname {}

variable lastname {
    type = string
    default = "Rathi"
}

#terraform features we also define any varibale dafault value then terraform not ask and
# if you want enter your value then you enter terraform plan -var 

#terraform have different kind of types
#string
#numeric
#bool
#list
#If we use type then variable specified which value store