* /etc/ngnix/
* ls 
* sudo nano sites-available
(copy paste below code)
{change your requirement according:-
path - /layout
port - 3000

}

location /layout {
        proxy_pass      http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header  Host $http_host;
        proxy_set_header  X-Forwarded-Proto $scheme;
        proxy_buffering   off;
        proxy_read_timeout   300;
    }

  location /css {
        proxy_pass        http://localhost:3000/css;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header  Host $http_host;
        proxy_set_header  X-Forwarded-Proto $scheme;
    }

    location /js {
        proxy_pass        http://localhost:3000/js;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header  Host $http_host;
        proxy_set_header  X-Forwarded-Proto $scheme;
    }

* sudo rm dev.warepro.in (dns file name)
and copy sites-available to sites-enable

* sudo ln -s /etc/nginx/sites-available/dev.warepro.in /etc/nginx/sites-enabled/dev.warepro.in


*sudo nginx -t  (check Ok)

*sudo systemctl reload nginx

* sudo service ngnix status

* sudo netstat -plant | grep ':443'
Explain:-
    netstat shows network connections.

    -p shows the process ID (PID) and program name.

    -l shows only listening ports.

    -a shows all sockets (including listening and non-listening).

    -n shows numeric addresses (IP and port).

    t shows TCP connections.

    grep ':443' filters the result to only show lines related to port 443.

* telnet tissueculture.kdisc.kerala.gov.in 443

* nc -zv tissueculture.kdisc.kerala.gov.in 443
  (o/p :- Connection to tissueculture.kdisc.kerala.gov.in (117.239.77.73) 443 port [tcp/https] succeeded!)

   

