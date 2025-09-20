* certbot --version

* sudo certbot renew --dry-run

* sudo systemctl reload nginx


-----------------------------------
Automated:-

* systemctl list-timers | grep certbot

If not, add a cron job:

* sudo crontab -e

0 3 * * * certbot renew --quiet && systemctl reload nginx


Verify Renewal:-
* sudo openssl x509 -in /etc/letsencrypt/live/yourdomain.com/fullchain.pem -noout -dates

* sudo openssl x509 -in /etc/letsencrypt/live/tissueculture.kdisc.kerala.gov.in/fullchain.pem -noout -dates
see your expiry date