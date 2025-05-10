1. Change Period closed and open:-
	Adempiere both functionality possible 
	search Accounting Schema and open your dafault Accounting Schema
	If you are direct un check box press (Automatic Period Control) automatic Period closed cancel .
	and your requirement Automatic Period Control check box press then you customization for our requirement
		if your demand my receipt handle 15-30 days then you enter History days field how many days you enter like 15 or 30
		this functionality changed then suddanly reset catch then your changes is proper working 
		History days enter days open one more funtion like you also easily create back days billing
		Ex. today 19/10/2023 but your requirement bill create 5/10/2023 if possible you provide days your similar other wise you enter a date and
		 show pop up box period closed message


2. How to change date Format in adempiere:-
	login with System user 
	date pattern changes two ways:-
	 1) Direst search Language
	 2) go to menu tree->SystemAdmin->GeneralRules->SystemRules->Language

	 choose our languages like (India language no is 33)
	 and enter date pattern

3. Change Country name enter every time location wise :-
	login with System user
	enter language windows and which language choose for your system using requirement like india language no. is 33
	two check box click System language,Login Locale

	go to tenent login:-
	go to menu tree -> SystemAdmin->TenentRule->tenent
	choose Language field and save

	and your location by default set your requirement Country for language wise.

4. 	Time Zone change from database

	go to terminal:-
	cd /etc/postgresql/14/main/
	sudo nano postgresql.conf

	and change only one line and time zone set
	log_timezone = 'Asia/Kolkata'
