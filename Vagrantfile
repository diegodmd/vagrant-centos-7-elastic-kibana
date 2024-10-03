Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.hostname = "elastic"
  config.vm.network "private_network", ip: "192.168.1.2"
  config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ".vagrant/"
  config.vm.provision "shell", path: "provision.sh"
  config.vbguest.auto_update = false
  config.vbguest.no_remote = true
  config.vbguest.installer_options = { allow_kernel_upgrade: true }
  config.vm.provider 'virtualbox' do |v|
    v.memory=4096
  end
end