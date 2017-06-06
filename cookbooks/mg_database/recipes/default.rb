#
# Cookbook:: database
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

conninfo = data_bag_item('passwords', 'mysql')

rpm_file = ::File.join(Chef::Config[:file_cache_path], 'mysql57-community-release-el7-11.noarch.rpm')
init_script = ::File.join(Chef::Config[:file_cache_path], 'init_script.sql')

# Write the SQL script to the filesystem.
cookbook_file rpm_file do
  source 'mysql57-community-release-el7-11.noarch.rpm'
end

rpm_package 'mysql57-community-release-el7-11.noarch.rpm' do
 source rpm_file
end

cookbook_file '/etc/yum.repos.d/mysql-community.repo' do
  source 'mysql-community.repo'
end

template init_script do
  source 'init_script.sql.erb'
  owner 'root'
  group 'root'
  mode  '0644'
  variables(:dbpassword => conninfo['root_password'])
end

execute 'mysql_init' do
   command "mysqld --initialize --user=mysql --init-file=#{init_script}"
   action :nothing
end

package 'mysql-server' do 
#  options '--nogpgcheck'
  notifies :run, 'execute[mysql_init]', :immediate
end

service 'mysqld' do
  action [:enable, :start]
end

# Install the mysql2 Ruby gem.
mysql2_chef_gem 'default' do
  action :install
end

mysql_connection_info = {
  host: '127.0.0.1',
  username: 'root',
  password: conninfo['root_password']
}

# Create the database instance.
mysql_database node['mysql']['database']['dbname'] do
  connection mysql_connection_info
  action :create
end

# Add a database user.
mysql_database_user conninfo['admin_user'] do
  connection mysql_connection_info
  password conninfo['admin_password']
  database_name node['mysql']['database']['dbname']
  host 'localhost'
  action [:create, :grant]
end

# Add a database user.
mysql_database_user conninfo['admin_user'] do
  connection mysql_connection_info
  password conninfo['admin_password']
  database_name node['mysql']['database']['dbname']
  host node['tomcat-node1-marc']['ipaddress']
  action [:create, :grant]
end

include_recipe 'mg_database::database_insert_data'
