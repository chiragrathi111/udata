🚀 1. Install Nginx

sudo apt update
sudo apt install nginx -y

sudo systemctl start nginx
sudo systemctl enable nginx

sudo systemctl status nginx

⚙️ 2. Create Nginx config

sudo nano /etc/nginx/sites-available/pierp.pipra.solutions

server {

        listen 80;
        listen [::]:80;
	
        root /var/www/html;

        # Add index.php to the list if you are using PHP
	index index.html;
	
	server_name pierp.pipra.solutions;

	location / {
        	# First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
	}
}

🔗 3. Enable config

sudo ln -s /etc/nginx/sites-available/pierp.pipra.solutions /etc/nginx/sites-enabled/

sudo nginx -t   (test)

sudo systemctl reload nginx

🔒 4. Install Certbot (SSL)

sudo apt install certbot python3-certbot-nginx -y

🔐 5. Generate SSL

sudo certbot --nginx -d pierp.pipra.solutions

👉 It will ask:

Email → enter
Agree → Yes
Redirect HTTP → HTTPS → Choose YES

✅ 6. Verify SSL

ping pierp.pipra.solutions

https://pierp.pipra.solutions

🔄 7. Auto-renew SSL

sudo certbot renew --dry-run