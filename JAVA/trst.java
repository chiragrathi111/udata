Prime :- 
int user_number = 10;
int count = 0;
for(int i = 2 i<user_number; i++){
	if(user_number % i == 0){
		count ++;
	}
}
if(count > 0){
	System.out.println("The No. is not a Prime Number");
}else{
	System.out.println("The No. is Prime Number");
}
-------------------
Corrected :-
Scanner scan = new Scanner(System.in);
int user = scan.nextInt();
if (user <= 1){
	System.out.println("This is not a Prime Number");
}
boolean isPrime = true;
for(int i = 2; i <= Math.sqrt(user); i++){
	if (user % i == 0)
{
	isPrime = false;
	break;
}		
}
if (isPrime){
	System.out.println("This is a Prime Number");
}else{
	System.out.println("This is not a Prime Number");
}
	

=================================================================================================
Palidrome :-

Scanner scan = new Scanner(System.in);
int number = scan.nextInt();
int digits = String.valueOf(number).length();
int tem = number;
int lastDigit, reversed = 0;
while(digits >= 1){
	lastDigit = tem % 10;
	reversed = reversed * 10 + lastDigit;
	tem = tem / 10;
	digits --;
}
if (number == reversed ){
	System.out.println("This number is Palidrome");
}else{
	System.out.println("This is not a Palidrome Number");
}
=====================================================================================================
Armstrong :- 

Scanner scan = new Scanner(System.in);
int number = scan.nextInt();
int digits = String.valueOf(number).length();
int digitCount = String.valueOf(number).length();
int lastDigit = 0, total = 0;
int tem = number;

while (digits >= 1){
	lastDigit = tem % 10;
	total = total + (int) (Math.pov(lastDigit,digitCount));
	tem = tem /10;
	digits --;
}
if (number ==total){
	System.out.println("This is a Armstrong Number");
}else{
	System.out.println("This is not a Armstrong Number");
}
=======================================================================================================
