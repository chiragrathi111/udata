Commands:-

* sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
* sudo nginx -t
* sudo systemctl reload nginx (mostly use reload)
* sudo systemctl restart nginx (This avoids downtime)

Idempiere:-

Increase iDempiere session

$IDEMPIERE_HOME/tomcat/conf/web.xml

<session-timeout>120</session-timeout>


