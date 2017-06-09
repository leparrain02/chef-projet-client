#!/bin/bash

nb_tomcat=3

berks install
berks upload

knife cookbook upload mg_database
knife cookbook upload tomcat
knife cookbook upload mg_web

echo "Creating role database"
knife role from file role_database.json
knife role run_list add database recipe[mg_database::default]

echo "Installing database node"
./deploy_vsphere_machine.sh db-node1-marc vstemplate-centos7
echo "Adding db-node1-marc to role database"
knife node run_list add db-node1-marc 'role[database]'



echo "Creating role app"
knife role from file role_app.json
knife role run_list add app recipe[tomcat::default]

echo "Installing app node"
cmpt=1
while [[ ${cmpt} -le ${nb_tomcat} ]]; do
  ./deploy_vsphere_machine.sh app-node${cmpt}-marc vstemplate-centos7
  echo "Adding app-node${cmpt}-marc to role app"
  knife node run_list add app-node${cmpt}-marc 'role[app]'
  cmpt=$((cmpt+1))
done
  


echo "Creating role web"
knife role from file role_web.json
knife role run_list add web recipe[mg_web::default]

echo "Installing web node"
./deploy_vsphere_machine.sh web-node1-marc vstemplate-centos7
echo "Adding web-node1-marc to role web"
knife node run_list add web-node1-marc 'role[web]'


echo "Creating data bags passwords"
knife data bag create passwords
knife data bag from file passwords cookbooks/mg_database/test/fixtures/default/data_bags/passwords/

#knife ssh 'name:web-node1-marc' 'sudo chef-client' --ssh-user root --ssh-password 'qwerty' --attribute ipaddress
