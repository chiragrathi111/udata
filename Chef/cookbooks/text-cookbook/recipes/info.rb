#
# Cookbook:: text-cookbook
# Recipe:: info
#
# Copyright:: 2025, The Authors, All Rights Reserved.

file '/home/chirag/ram/info' do
content " This is a basic information our device
HOSTNAME: #{node['hostname']}
RAM: #{node['memory']['total']}
CPU: #{node['cpu']['0']['mhz']}"
owner 'chirag'
group 'chirag'
action :create
end 
