#
# Cookbook:: tomcat
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

conninfo = data_bag_item('passwords', 'mysql')

firewall 'default' do
  action :install
end

firewall_rule 'ssh' do
  port 22
  command :allow
end

package 'java-1.7.0-openjdk-devel' do
end

group node['tomcat']['group']

user node['tomcat']['username'] do
  group node['tomcat']['group']
  shell '/bin/nologin'
  home '/opt/tomcat'
  manage_home false
end

directory '/opt/tomcat' do
end

tar_extract "http://apache.mirror.colo-serv.net/tomcat/tomcat-8/v#{node['tomcat']['version']}/bin/apache-tomcat-#{node['tomcat']['version']}.tar.gz" do
  target_dir '/opt/tomcat'
  creates "/opt/tomcat/apache-tomcat-#{node['tomcat']['version']}/lib"
end


fileutils "/opt/tomcat/apache-tomcat-#{node['tomcat']['version']}/conf" do
  group node['tomcat']['group']
  file_mode 'g+r'
  directory_mode 'g+rx'
  recursive true
  not_if "stat -c '%G' /opt/tomcat/apache-tomcat-#{node['tomcat']['version']}/conf|grep '^ *tomcat *$'"
end

cookbook_file "/opt/tomcat/apache-tomcat-#{node['tomcat']['version']}/lib/mysql-connector-java-5.1.42-bin.jar" do
  source 'mysql-connector-java-5.1.42-bin.jar'
  user 'root'
  group 'tomcat'
  mode '0640'
end

%w( webapps work temp logs).each do |repertoire|
  fileutils "/opt/tomcat/apache-tomcat-#{node['tomcat']['version']}/#{repertoire}" do
    owner node['tomcat']['username']
    recursive true
    not_if "stat -c '%U' /opt/tomcat/apache-tomcat-#{node['tomcat']['version']}/#{repertoire}|grep '^ *tomcat *$'"
  end
end

fileutils "/opt/tomcat/apache-tomcat-#{node['tomcat']['version']}" do
  group node['tomcat']['group']
  recursive true
  not_if "stat -c '%G' /opt/tomcat/apache-tomcat-#{node['tomcat']['version']}|grep '^ *tomcat *$'"
end

execute 'daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end 

template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service.erb'
  owner  'root'
  group  'root'
  mode   '0644'
  notifies :run, 'execute[daemon-reload]', :immediate
end

service 'tomcat' do
  action [:enable, :start]
end

if node['kitchen'] then 
  nodename = 'node1'
else
  nodename = node['name']
end

template "/opt/tomcat/apache-tomcat-#{node['tomcat']['version']}/conf/server.xml" do
  source 'server.xml.erb'
  variables(:workername => nodename)
  notifies :restart, 'service[tomcat]', :immediate
end

workdir = ::File.join(Chef::Config[:file_cache_path], 'webapps')
wardir = "#{workdir}/#{node['tomcat']['servicename']}"

directory wardir do
  recursive true
end

cookbook_file "#{workdir}/#{node['tomcat']['servicename']}.war" do
  source "#{node['tomcat']['servicename']}.war"
end

execute 'expand_service' do
  command "jar xf ../#{node['tomcat']['servicename']}.war"
  cwd wardir
end


dbservers=search(:node,'role:database',:filter_result => { 'IP' => ['ipaddress']})

if defined?(dbservers) && !dbservers.empty? then
  dbserver=dbservers[0]['IP']
else
  dbserver=node['database']['server']
end

template "#{wardir}/META-INF/context.xml" do
  source 'context.xml.erb'
  variables(:dbusername => conninfo['admin_user'],
       :dbpassword => conninfo['admin_password'],
       :dbserver => dbserver,
       :dbport   => node['database']['port'],
       :dbname   => node['database']['dbname']
  )
end

execute 'create_jar' do
  command "jar cf /opt/tomcat/apache-tomcat-#{node['tomcat']['version']}/webapps/#{node['tomcat']['servicename']}.war *" 
  cwd wardir
end

webservers=search(:node,'role:web',:filter_result => { 'IP' => ['ipaddress']})

if defined?(webservers) && !webservers.empty? then
  webserver=webservers[0]['IP']
else
  webserver=node['web']['server']
end

firewall_rule 'webserver' do
  port 8009
  source webserver
  command :allow
end
