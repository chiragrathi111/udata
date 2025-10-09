Install Chef using Command:-
 * curl -L https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chef-workstation
 * which chef
 * chef --version

 
 
 
 * wget https://packages.chef.io/files/stable/chef-workstation/25.5.1084/ubuntu/22.04/chef-workstation_25.5.1084-1_amd64.deb
 * 

 =========================================
Commands:-
  * mkdir cookbooks
  * cd cookbooks/
  * ls
  * chef generate cookbook text-cookbook
  * ls
  * tree
  * sudo apt install tree
  * tree
  * cd text-cookbook/
  * tree
  * chef generate recipe test-1
  * tree
  * cd ..
  * nano text-cookbook/recipes/test-1.rb
  * chef exec ruby -c text-cookbook/recipes/test-1.rb
  * chef-client -zr "recipe[text-cookbook::test-1]"
  * cat ~/myfilec
  * chef-client -zr "recipe[text-cookbook::test-1]"

+++++++++++++++++++++++++++++++++++++++++++
Commands2:-
 * ohai
 * ohai ipaddress
 * ohai memory/total
 * ohai cpu
 * ls
 * cd text-cookbook/
 * chef generate recipe info
 * ls
 * tree
 * cd ..
 * nano text-cookbook/recipes/info.rb 
 * chef exec ruby -c text-cookbook/recipes/info.rb 
 * chef-client -zr "recipe[text-cookbook::info]"
 * ls -l /home/chirag/
 * ls -l /home/chirag/ram
 * cat /home/chirag/ram/info 

+++++++++++++++++++++++++++++++++++++++++++
Command3:-
 