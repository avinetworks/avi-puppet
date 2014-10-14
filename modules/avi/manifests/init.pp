# Avi Module
# Create and update objects in avi controller.

class avi {
    file { '/root/configs/lb.json':
        ensure => file,
        path   => '/root/configs/lb.json',
        source => 'puppet:///modules/avi/lb.json'
    }
    file { '/opt/avi/python/bin/utils/config_import.py':
        ensure => 'present',
        audit  => 'all',
    }
    exec { 'python /opt/avi/python/bin/utils/config_import.py \
           --command "import configuration file /root/configs/lb.json"':
        path    => '/bin:/usr/bin:/usr/sbin/sbin',
        require => File['/root/configs/lb.json',
                        '/opt/avi/python/bin/utils/config_import.py']
    }
}
