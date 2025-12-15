# Terraform Function: F11

# String Functions:-
# Their have two type of functions (uppere, lower)
# If you want to go to terraform console
# terraform console  //it this commands
# upper("hello")  // it will return "HELLO"
# lower("HELLO")  // it will return "hello"
# trim("  hello  ")  // it will return "hello"
# trimspace("  hello  ")  // it will return "hello"
# split(",", "hello,world")  // it will return ["hello", "world"
# join(["hello", "world"], ",")  // it will return "hello,world"
# replace("hello world", "world", "terraform")  // it will return "hello terraform"
# length("hello")  // it will return 5
# substr("hello", 0, 2)  // it will return "he"
# contains(["apple", "banana", "cherry"], "banana")  // it will return true
# format("Hello, %s!", "world")  // it will return "Hello, world!"
# title("hello world")  // it will return "Hello World"
# capitalize("hello")  // it will return "Hello"
# reverse("hello")  // it will return "olleh"
# regex("hello123", "[0-9]+")  // it will return ["123"]
# replace_regex("hello123", "[0-9]+", "world")  // it will return "helloworld"
# substr("hello", 1, 3)  // it will return "ell"


# Number Functions:-
# Their have two type of functions (max, min)
# If you want to go to terraform console
# terraform console  //it this commands
# max(1, 2, 3)  // it will return 3
# min(1, 2, 3)  // it will return 1
# abs(-5)  // it will return 5
# ceil(4.3)  // it will return 5
# floor(4.7)  // it will return 4
# round(4.5)  // it will return 5
# sqrt(16)  // it will return 4
# pow(2, 3)  // it will return 8
# log(100, 10)  // it will return 2
# random_integer(1, 10)  // it will return a random integer between 1 and 10
# random_float(0.0, 1.0)  // it will return a random float between 0.0 and 1.0
# random_shuffle(["a", "b", "c", "d"])  // it will return a random permutation of the list
# sum([1, 2, 3, 4, 5])  // it will return 15
# average([1, 2, 3, 4, 5])  // it will return 3
# ceil(4.2)  // it will return 5
# floor(4.8)  // it will return 4
# round(4.5)  // it will return 5
# mod(10, 3)  // it will return 1
# int("42")  // it will return 42
# float("3.14")  // it will return 3.14
# tonumber("100")  // it will return 100
# clamp(5, 1, 10)  // it will return 5
# sign(-10)  // it will return -1
# log10(1000)  // it will return 3
# exp(2)  // it will return 7.38905609893065
# hypot(3, 4)  // it will return 5  


# Date and Time Functions:-
# Their have two type of functions (formatdate, timeadd)
# If you want to go to terraform console
# terraform console  //it this commands
# formatdate("YYYY-MM-DD", timestamp())  // it will return current date in "YYYY-MM-DD" format
# timeadd(timestamp(), "24h")  // it will return timestamp plus 24 hours
# timecmp(timestamp(), timeadd(timestamp(), "1h"))  // it will return -1
# timestamp()  // it will return current timestamp in RFC3339 format
# formatdate("YYYY-MM-DD HH:mm:ss", timestamp())  // it will return current date and time in "YYYY-MM-DD HH:mm:ss" format
# timesubtract(timestamp(), "1h")  // it will return timestamp minus 1 hour
# timeparse("2023-01-01T00:00:00Z", "YYYY-MM-DDTHH:mm:ssZ")  // it will return timestamp for the given date and time
# dayofmonth(timestamp())  // it will return current day of the month
# month(timestamp())  // it will return current month
# year(timestamp())  // it will return current year
# dayofweek(timestamp())  // it will return current day of the week (0=Sunday, 6=Saturday)
# hour(timestamp())  // it will return current hour
# minute(timestamp())  // it will return current minute
# second(timestamp())  // it will return current second
# weekday(timestamp())  // it will return current weekday name (e.g., "Monday")
# isodate(timestamp())  // it will return current date in ISO 8601 format
# rfc3339(timestamp())  // it will return current timestamp in RFC 3339 format


# Lookup Functions:-
# Their have two type of functions (lookup, contains)
# If you want to go to terraform console
# terraform console  //it this commands
# lookup({"a" = 1, "b" = 2}, "a", 0)  // it will return 1
# contains(["apple", "banana", "cherry"], "banana")  // it will return true
# element(["a", "b", "c"], 1)  // it will return "b"
# index(["a", "b", "c"], "b")  // it will return 1
# keys({"a" = 1, "b" = 2})  // it will return ["a", "b"]
# values({"a" = 1, "b" = 2})  // it will return [1, 2]
# length(["a", "b", "c"])  // it will return 3
# merge({"a" = 1}, {"b" = 2})  // it will return {"a" = 1, "b" = 2}
# zipmap(["a", "b"], [1, 2])  // it will return {"a" = 1, "b" = 2}
# map("a", 1, "b", 2)  // it will return {"a" = 1, "b" = 2}
# flatten([["a", "b"], ["c", "d"]])  // it will return ["a", "b", "c", "d"]
# chunklist(["a", "b", "c", "d"], 2)  // it will return [["a", "b"], ["c", "d"]

# give me more example for lookup function in terraform
# lookup({"a" = 1, "b" = 2}, "a", 0)  // it will return 1
# lookup({"name" = "John", "age" = 30}, "name", "Unknown")  // it will return "John"
# lookup({"name" = "John", "age" = 30}, "gender", "Unknown")  // it will return "Unknown"
# lookup(var.my_map, "key1", "default_value")  // it will return the value of "key1" in var.my_map or "default_value" if "key1 does not exist
# lookup({"x" = 10, "y" = 20}, "y", 0)  // it will return 20
# lookup({"x" = 10, "y" = 20}, "z", 0)  // it will return 0

# Means Lookup function is used to retrieve thhe value of a specified key from a map, if your entered key not match it will return default value.
# terraform example:-
# variable "config" {
#   type = map(string)
#   default = {
#     dev = "us-west-2"
#     prod = "us-east-1"
#   }
# lookup(var.config, "dev", "ap-south-1")  //

# Validation Functions:-
# Their have two type of functions (can, cannot)
# If you want to go to terraform
# ive me more example for validation function in terraform
# can(1 + 1)  // it will return true
# can(length("hello"))  // it will return true

# variable "x" {
#   type = number
#   validation {
#     condition = can(1 + 1)
#     error_message = "1 + 1 is not 2"
#   }

variable "instance_type" {
    default = "t2.micro"

    validation {
      condition = length(var.instance_type) >=2 && length(var.instance_type <=20)
      error_message = "instance type must be between 2 to 20 character"
    }

    validation {
      condition = can(regex("^t[2-3]\\.", var.instance_type))
      error_message = "Instance type must be t2 or t3"
    }
}

# sensitive variable example:-
variable "db_password" {
  type      = string
  sensitive = true  //this will hide the value of the variable in the terraform plan and apply output
}