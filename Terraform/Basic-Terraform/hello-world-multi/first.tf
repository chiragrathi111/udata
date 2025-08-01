output "first" {
  value = "Chirag Rathi"
}

output "second" {
  value = "Abhishek Rathi"
}
output "three" {
  value = "Chandresh Rathi"
}

output "four" {
  value = "Kishan Rathi"
}

output "five" {
  value = "Kanha Rathi"
}
# If we are write output defination name same then we will throw message 
#because Defination name every time unique
#Error: Duplicate output definition


#I Observe output defination name you write any sequense but by default 
# It is show Alphabetic Sequense

#if you want your terraformfile actualformat then use below command
#terraform fmt
