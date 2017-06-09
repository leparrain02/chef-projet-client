# Create the document root directory.
directory node['apache']['web']['document_root'] do
  recursive true
end

# Install Apache and start the service.
httpd_service 'default' do
  mpm 'prefork'
  action [:create, :start]
  subscribes :restart, 'httpd_config[default]'
end

cookbook_file '/etc/httpd-default/modules/mod_jk.so' do
  source 'mod_jk.so'
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/httpd-default/conf.modules.d/jk.load' do
  source 'jk.load.erb'
  owner 'root'
  group 'root'
  mode  '0644'
end

template '/etc/httpd-default/conf.modules.d/jk.conf' do
  source 'jk.conf.erb'
  owner 'root'
  group 'root'
  mode  '0644'
  variables(:servicename => node['tomcat']['servicename'])
end

apps={};
appservers=search(:node,'role:app',:filter_result => { 'IP' => ['ipaddress']})
if(!appservers.empty?) then
  appservers.each_index do |index|
    apps["node#{index+1}"] = appservers[index]['IP']
  end
  puts "Node list est: " + apps.keys.join(",")
else
  apps["node1"] = node['tomcat']['host']
end

template '/etc/httpd-default/conf.modules.d/workers.properties' do
  source 'workers.properties.erb'
  owner 'root'
  group 'root'
  mode  '0644'
  variables({:appservers => apps,
             :nodelist   => apps.keys.join(", ") })
end

# Add the site configuration.
httpd_config 'default' do
  source 'default.conf.erb'
end


service 'httpd-default' do
  action :restart
end


service 'firewalld' do
  action [:disable, :stop]
end

