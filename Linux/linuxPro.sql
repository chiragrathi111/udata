find /opt -name "*.jar" 2>/dev/null | grep rwpl | sort

Meaning:

find → search files
2>/dev/null → hide errors
grep rwpl → filter
sort → organize

--------------------------------------------------------

find / -path "*/.config" -prune -o -name "*.dmp" -print 2>/dev/null

Recently modified :-

find /opt -mtime -1

Case-insensitive :-

find / -iname "*idempiere*"

Large files

find / -size +500M 

Skiped The file :-

-path "*/.config" -prune 
----------------------------------------------------------
Search inside files :-

grep -Ri "ERROR" /opt/idempiere-server/log

Show line numbers :-

grep -Rin "Exception" .
----------------------------------------------------------
Last 100 lines :-

tail -100 idempiere.log
-----------------------------------------------------------
Deep Search :-

du -h --max-depth=1
-------------------------------------------------------------
Heap info :-

jmap -heap PID
--------------------------------------------------------------
Most Important Linux Operators

Operator	Meaning
`	`
>			overwrite file
>>			append
2>/dev/null	hide errors
&&			run next if success
;			run sequentially


