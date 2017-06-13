#
# Cookbook:: bjc_ecom_proxy
# Recipe:: default
#
# Copyright:: 2017, Nick Rycar, All Rights Reserved.

haproxy_install 'package'

haproxy_config_global 'default' do
  chroot '/var/lib/haproxy'
  daemon true
  maxconn 256
  log '/dev/log local0'
  log_tag 'WARDEN'
  pidfile '/var/run/haproxy.pid'
  stats socket: '/var/lib/haproxy/stats level admin'
  tuning 'bufsize' => '262144'
end

haproxy_config_defaults 'default' do
  mode 'http'
  timeout connect: '5000ms',
          client: '5000ms',
          server: '5000ms'
end

haproxy_frontend 'http-in' do
  bind '*:80'
  default_backend 'servers'
end

haproxy_backend 'servers' do
  search(:node, 'chef_environment:delivered AND recipes:bjc-ecommerce',
                      filter_result: {
                        name: ['name'],
                        ip: [%w(ec2 public_ipv4)],
                      }).each do |webserver|
    server ["#{webserver[:name]} #{webserver[:ip]}:80 maxconn 32"]
  end
end
