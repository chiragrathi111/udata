Commands:-

* sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
* sudo nginx -t
* sudo systemctl reload nginx (mostly use reload)
* sudo systemctl restart nginx (This avoids downtime)

Idempiere:-

Increase iDempiere session


✅ 1. JVM Memory (VERY IMPORTANT)

/opt/idempiere-server/idempiereEnv.properties

IDEMPIERE_JAVA_OPTIONS=-Xms3G -Xmx5G -XX:+UseG1GC -XX:MaxGCPauseMillis=200


✅ 2. ZK Session Timeout (ROOT CAUSE OF LOGOUT)

/opt/idempiere-server/jettyhome/etc/webdefault.xml

<session-timeout>120</session-timeout>

✅ 3. Increase ZK Desktop Timeout (VERY IMPORTANT)

IDEMPIERE_JAVA_OPTIONS=-Xms3G -Xmx5G -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Dorg.zkoss.zk.ui.session.timeout=7200


✅ 4. Fix Nginx Timeout (YOU MISSED THIS ❗)

# GLOBAL TIMEOUT FIX
proxy_connect_timeout 300;
proxy_send_timeout    300;
proxy_read_timeout    3600;
send_timeout          300;

# KEEP ALIVE
keepalive_timeout 75;

sudo nginx -t
sudo systemctl restart nginx

✅ 5. Jetty Thread Optimization

/opt/idempiere-server/jettyhome/etc/jetty-threadpool.xml

<Set name="minThreads">20</Set>
<Set name="maxThreads">200</Set>
<Set name="idleTimeout">60000</Set>

✅ 6. Database (IMPORTANT)

/etc/postgresql/14/main/postgresql.conf

shared_buffers = 1GB
work_mem = 16MB
maintenance_work_mem = 256MB

sudo systemctl restart postgresql