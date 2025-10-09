file '/myfile' do
content 'Welcome to Technical Guftgu'
action :create
end

*********


package 'tree' do
action :install
end

file '/myfile2' do
content 'This is My Second Project code'
action :create
owner 'root'
group 'root'
end

*********
package 'httpd' do
action :install
end

file '/var/www/html/index.html' do
content 'Welcome to Technical Guftgu'
action :create
end


service 'httpd' do
action [:enable, :start]
end

*********************
file '/basicinfo' do
 content "This is to get Attributes
 HOSTNAME: #{node['hostname']}
 IPADDRESS: #{node['ipaddress']}
 CPU: #{node['cpu']['0']['mhz']}
 MEMORY: #{node['memory']['total']}"
 owner 'root'
 group 'root'
action :create
end

***************************