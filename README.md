Devbox Puppet Config
====================

This is my personal puppet configuration which I use with vagrant to setup my development box.

It installs the following:
* PHP 5.4
* Apache 2.2
* MySQL 5.5
* Memcache 3.0
* Redis 2.4
* Git
* Various php dev tools (phpunit, phing, phpmyadmin, etc)
* Vim
* ZSH and oh-my-zsh (default shell)
* capistrano
* compass

It has been tested with a Ubuntu precise64 box.

Requirements
------------

* Puppet
* Vagrant

Usage
-----

Create a Vagrantfile in the root of your project with the following contents:

```
Vagrant::Config.run do |config|
    config.vm.box = "precise64"
    config.vm.network :hostonly, "33.33.33.10"
    config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "puppet/manifests"
        puppet.module_path = "puppet/modules"
        puppet.manifest_file  = "site.pp"
        puppet.options = "--verbose"
    end
end
```

Create a puppet directory that will hold your manifests.

```
$ mkdir -p puppet/manifests
```

Now create a the ```puppet/manifests/site.pp``` file with the following:
```
class { "devbox":
    hostname => "some-dev-box", # Make sure this maps to the address above
    gitUser => "Your full name",
    gitEmail => "Your email address"
}
```

Run vagrant up to start downloading (if the box hasn't been downloaded yet) and initializing your machine:
```
vagrant up
```

Now you can run ```vagrant ssh``` to login to your box.

The ```web``` directory in your project dir will be served by Apache.

To access phpMyAdmin you can just enter the IP address of the machine in your browser or any other hostname than provided above that maps to that IP address.

