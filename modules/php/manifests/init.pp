class php {
    # Install PHP packages
    $phpPackages = ["php5", "php5-cli", "php5-mysql", "php-pear", "php5-dev", "php-apc", "php5-mcrypt", "php5-gd", "php5-sqlite", "php5-curl", "php5-intl", "php5-xdebug", "php5-memcache"]
    package { $phpPackages:
        ensure => latest,
        require => [Exec['apt-get update'], Package['apache2']],
    }

    # Change configuration files
    file { "/etc/php5/cli/php.ini":
        ensure => file,
        owner => "root",
        group => "root",
        source => "puppet:///modules/php/php-cli.ini",
        require => Package['php5-cli'],
    }
    file { "/etc/php5/apache2filter/php.ini":
        ensure => file,
        owner => "root",
        group => "root",
        source => "puppet:///modules/php/php-web.ini",
        notify => Service["apache2"],
        require => Package['php5'],
    }

    # Ensure session folder is writable by Vagrant user (under which apache runs)
    file { "/var/lib/php5/session" :
        owner  => "root",
        group  => "vagrant",
        mode   => 0770,
        require => Package["php5"],
    }

    # Install image magick extension. Upstream has problems, so we have to install
    # the package manually.
    package { "imagemagick":
        ensure => latest,
        require => Exec['apt-get update'],
    }
    exec { "php.imagick.download":
        command => "wget https://launchpad.net/~ondrej/+archive/php5/+files/php5-imagick_3.1.0%7Erc1-1%7Eprecise%2B1_amd64.deb -O /tmp/php5-imagick.deb",
        creates => "/tmp/php5-imagick.deb",
        unless => "dpkg -l php5-imagick | grep ii",
        require => Package['php5']
    }
    exec { "php.imagick.install":
        command => "dpkg -i /tmp/php5-imagick.deb",
        unless => "dpkg -l php5-imagick | grep ii",
        require => [Package['imagemagick'], Exec["php.imagick.download"]],
        notify => Service["apache2"]
    }

    # Install various PEAR packages
    exec { "pear upgrade":
        command => "pear upgrade",
        require => [Package['php5-cli'], Package['php-pear']],
    }
    exec { "pear auto-discover":
        command => "pear config-set auto_discover 1 system",
        unless => "pear config-get auto_discover system | grep 1",
        require => Exec['pear upgrade'],
    }
    exec { "pear-phpunit":
        command => "pear install --alldeps pear.phpunit.de/PHPUnit",
        unless => "pear info pear.phpunit.de/PHPUnit",
        require => Exec['pear auto-discover'],
    }
    exec { "pear-phpcpd":
        command => "pear install pear.phpunit.de/phpcpd",
        unless => "pear info pear.phpunit.de/phpcpd",
        require => Exec['pear auto-discover'],
    }
    exec { "pear-phploc":
        command => "pear install pear.phpunit.de/phploc",
        unless => "pear info pear.phpunit.de/phploc",
        require => Exec['pear auto-discover'],
    }
    exec { "pear-phpmd":
        command => "pear install --alldeps pear.phpmd.org/PHP_PMD",
        unless => "pear info pear.phpmd.org/PHP_PMD",
        require => Exec['pear auto-discover'],
    }
    exec { "pear-phpdoc":
        command => "pear install pear.phpdoc.org/phpDocumentor-alpha",
        unless => "pear info pear.phpdoc.org/phpDocumentor-alpha",
        require => Exec['pear auto-discover'],
    }
    exec { "pear-phing":
        command => "pear install pear.phing.info/phing",
        unless => "pear info pear.phing.info/phing",
        require => Exec['pear auto-discover'],
    }

    # Add a phpinfo file to www root
    file { "/var/www/phpinfo.php":
        content => "<?php phpinfo();",
        require => Package['apache2']
    }
}