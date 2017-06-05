# See https://docs.getchef.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "admin"
client_key               "#{current_dir}/admin.pem"
chef_server_url          "https://chef-server-marc.collegemultihexa.ca/organizations/marcg"
cookbook_path            ["#{current_dir}/../cookbooks"]

knife[:vsphere_host] = "vcenterdevo.collegemultihexa.ca"
knife[:vsphere_user] = "administrator@vsphere.local" # Domain logins may need to be "user@domain.com"
knife[:vsphere_pass] = "P@ssw0rd"       # or %Q(mypasswordwithfunnycharacters)
knife[:vsphere_dc] = "Local C9"
knife[:vsphere_insecure] = true
