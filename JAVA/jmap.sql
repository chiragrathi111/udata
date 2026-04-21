ps -ef | grep java

jstat -gc <PID> 5000  (every 5 sec check)

if OU value increse means memeory leak sign

3000 → 3500 → 3900 → 4000

jmap -histo:live <PID> | head -20