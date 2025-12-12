# Variable using Low to high:-

# 1. default value (if no value is provided, this value will be used by default)
variable "example_variable" {
  type    = string
  default = "default_value"
}

# 2. ENV variable (if an environment variable with the same name exists, it will override the default value)
   # example: export TF_VAR_example_variable="env_value"

# 3. terraform.tfvars file (if a value is provided in this file, it will override both the default and environment variable values)
   # example content of terraform.tfvars:
   # example_variable = "tfvars_value"

# 4. terraform.tfvars.json file (if a value is provided in this JSON file, it will override the previous values)
   # example content of terraform.tfvars.json:
   # {
   #   "example_variable": "tfvars_json_value"
   # }

# 5. *.auto.tfvars file (if a value is provided in this file, it will override all previous values)
   # example content of example.auto.tfvars:
   # example_variable = "auto_tfvars_value"

#  6. *.auto.tfvars.json file (if a value is provided in this JSON file, it will override all previous values)
   # example content of example.auto.tfvars.json:
   # {
   #   "example_variable": "auto_tfvars_json_value"
   # }

# 7. ANY - var OR -var-file option in the command line (if a value is provided using these options, it will override all previous values)
   # example command:
   # terraform apply -var="example_variable=cli_value"
   # or
   # terraform apply -var-file="custom_values.tfvars"