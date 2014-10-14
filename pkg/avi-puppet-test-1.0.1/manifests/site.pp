# /etc/puppet/manifests/site.pp

node 'puppet-controller.avi.local' {
    include avi
}
