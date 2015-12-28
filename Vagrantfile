# -*- mode: ruby -*-
# vi: set ft=ruby :

movies_path     = "/Volumes/Media Center/Shared iTunes/iTunes Media/Movies"
puppet_modules  = "treydock-gpg_key puppetlabs-nodejs"

Vagrant.configure(2) do |config|
  config.vm.box = "puppetlabs/centos-7.0-64-puppet"

  # Application is running on port 9000, open http://localhost:9000
  config.vm.network "forwarded_port", guest: 9000, host: 9000
  # Required for LiveReload to reload changes automatically
  config.vm.network "forwarded_port", guest: 35729, host: 35729

  # Current directory is the Workspace
  config.vm.synced_folder ".", "/home/vagrant/workspace"
  # Shared directory to all the movies in iTunes
  config.vm.synced_folder movies_path, "/home/vagrant/movies"

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  config.vm.provision "shell", inline: <<-SHELL
    # treydock-gpg_key is required by nodejs but not included. https://github.com/willdurand/puppet-nodejs/issues/101
    for pm in treydock-gpg_key puppetlabs-nodejs
      do puppet module install -i /opt/puppetlabs/puppet/modules ${pm}
    done
  SHELL

  # Vagrant & Puppet 4: https://github.com/mitchellh/vagrant/issues/3740
  config.vm.provision "puppet" do |puppet|
    puppet.environment      = 'production'
    puppet.environment_path = 'puppet/environments'
    puppet.options          = [
        '--verbose',
        # '--trace',
        # '--debug',
    ]
  end

end
