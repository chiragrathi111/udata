#!/bin/bash

echo enter a first no.
read a
echo enter second no.
read b

sum=$(($a+$b))
min=$(($a-$b))
mul=$(($a*$b))
div=$(($a/$b))
mod=$(($a%$b))
echo sum is :
echo $a + $b :- $sum
echo Minus is :
echo $a - $b :- $min
echo Multiply is :
echo $a * $b :- $mul
echo divide is :
echo $a / $b :- $div
echo module is:
echo $a % $b :- $mod


Switch
#!/bin/bash

echo enter the no.
read a

case $a in
        1)date;;
        2)hostname;;
        3)pwd;;
        4)ls;;
        5)ps;;
        6)top;;
        7)mkdir;;
        *) echo invalid
esac


For loop

#!/bin/bash

# for loop practice

echo enter the table no. is :
read a

for b in {1..10}
do
mul=$(($a*$b))
        echo table is :- $a*$b : $mul
done


Until

#!/bin/bash

# until
echo enter the no.
read a / a=1
until [ $a -gt 10 ]
do
        echo $a
        ((a++))
done
echo loop expired


sudo systemctl start httpd.service

## html page host
sudo apt install apache2
  179  sudo apt-get update
  180  sudo apt-get upgrade
  181  sudo systemctl enable apache2
  182  sudo systemctl status apache2
  183  cd /var/www/
  184  ls -l
  185  sudo chmod 777 html
  186  ls -l
  187  cd html
  188  ls -l
  189  sudo cp index.html index1.html
  190  ls -l
  191  rm -rf index.html
  192  vi index.html

                   