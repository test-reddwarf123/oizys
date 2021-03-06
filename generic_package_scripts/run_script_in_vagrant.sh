# Get all the information required to ssh into the host vm and run ci
# Assume the first parameter is the REVNO for the package!!!!!
# 4th param == git key for access
vagrant_ssh() {
    VHOST=`vagrant ssh_config | awk '/HostName/{print $2}'`
    VUSER=`vagrant ssh_config | awk '/User /{print $2}'`
    VPORT=`vagrant ssh_config | awk '/Port/{print $2}'`
    VIDFILE=`vagrant ssh_config | awk '/IdentityFile/{print $2}'`
    ssh ${VUSER}@${VHOST} -p ${VPORT} -i ${VIDFILE} -o NoHostAuthenticationForLocalhost=yes "$@"
}

vagrant_ssh sh /vagrant/initialize.sh

if [ $2 == "all" ] || [ $2 == "nova" ]
then 
    echo "Packaging Nova"
    vagrant_ssh sh /vagrant/package_nova.sh $1 $3
    vagrant_ssh mv /home/vagrant/nova/nova_debs.tgz /vagrant
    # Now push the darn thing up to the repo
    git config --global user.name "jenkins-reddwarf"
    git config --global user.email "mbasnigh@rackspace.com"
    git config --global github.token $4
    git checkout master
    git commit nova_diablo_scripts/debian/changelog -m'Pushing a new changelog -- autogenerated'
    git push
    
fi

if [ $2 == "all" ] || [ $2 == "glance" ]
then 
    echo "Packaging Glance"
    vagrant_ssh sh /vagrant/package_glance.sh $1
    vagrant_ssh mv /home/vagrant/glance/glance_debs.tgz /vagrant
fi

if [ $2 == "all" ] || [ $2 == "novaclient" ]
then 
    echo "Packaging Nova Client"
    vagrant_ssh sh /vagrant/package_novaclient.sh $1
    vagrant_ssh mv /home/vagrant/novaclient/novaclient_debs.tgz /vagrant
fi

if [ $2 == "all" ] || [ $2 == "guest" ]
then 
    echo "Packaging Nova Guest"
    vagrant_ssh sh /vagrant/package_nova_guest.sh $1
    vagrant_ssh mv /home/vagrant/guest/guest_debs.tgz /vagrant
fi

if [ $2 == "all" ] || [ $2 == "swift" ]
then 
    echo "Packaging Swift"
    vagrant_ssh sh /vagrant/package_swift.sh $1
    vagrant_ssh mv /home/vagrant/swift/swift_debs.tgz /vagrant
fi