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
