conninfo = data_bag_item('passwords', 'mysql')

# Create a path to the SQL file in the Chef cache.
create_tables_script_path = ::File.join(Chef::Config[:file_cache_path], 'create-tables.sql')

# Write the SQL script to the filesystem.
cookbook_file create_tables_script_path do
  source 'create-tables.sql'
end

# Seed the database with a table and test data.
execute "initialize #{node['mysql']['database']['dbname']} database" do
  command "mysql -h 127.0.0.1 -u #{conninfo['admin_user']} -p#{conninfo['admin_password']} -D #{node['mysql']['database']['dbname']} < #{create_tables_script_path}"
  not_if  "mysql -h 127.0.0.1 -u #{conninfo['admin_user']} -p#{conninfo['admin_password']} -D #{node['mysql']['database']['dbname']} -e 'describe customers;'"
end
