#
# Cookbook:: test_search
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

webserver=search(:node,'role:web',:filter_result => { 'IP' => ['ipaddress']})

if(webserver) then
  puts "Le serveur web est #{webserver[0]['IP']}"
else
  puts "Le serveur web est le default"
end

apps={};
appservers=search(:node,'role:app',:filter_result => { 'IP' => ['ipaddress']})
if(appservers) then
  appservers.each_index do |index|
    apps["node#{index+1}"] = appservers[index]['IP']
    puts "Le serveur app node#{index+1} est #{appservers[index]['IP']}"
  end
  puts "Node list est: " + apps.keys.join(", ")
else
  puts "Le serveur app est le default"
end


dbserver=search(:node,'role:database',:filter_result => { 'IP' => ['ipaddress']})

if defined?(dbserver) && !dbserver.empty? then
  puts "Le serveur db est #{dbserver[0]['IP']}"
else
  puts "Le serveur db est le default"
end
