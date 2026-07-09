File Function :-

user_data = file("userdata.sh")

if we are use file() then terraform easily understand this is a file type not a simple text. 

jsonencode() :-

Terraform converts it into valid JSON automatically.

most using terraform Function :-

upper()

lower()

length()

join()

split()

lookup()

contains()

merge()

file()

templatefile()

jsonencode()

coalesce()

try()

Expression :-

instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"

app_name = "${var.environment}-backend"