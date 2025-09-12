Spring boot have 3 type log:-

logback:- Generally use this method

log4j2:- This is the one of the best feature

Java Util Logging(JUL) :- This is basic java log 


write a custom log file
src/main/resources
write this file name:-
spring.xml or logback.xml

@Slf4j
use this annotation no need to using below line directly use log object

private static final Logger logger = LoggerFactory.getLogger(<clasname>.class);


logging:
  level:
    net:
      engineeringdigest:
        journalApp: DEBUG

(INFO,WARN,ERROR ) this three by debault using 
if you want DEBUG and TRACE
so you wrote application.properties or application.yml file       