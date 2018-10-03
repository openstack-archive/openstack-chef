source 'https://supermarket.chef.io'

%w(
  integration-test
  orchestration
  telemetry
  block-storage
  common
  compute
  dashboard
  dns
  identity
  image
  network
  ops-database
  ops-messaging
  bare-metal
).each do |cookbook|
  if Dir.exist?("../cookbook-openstack-#{cookbook}")
    cookbook "openstack-#{cookbook}", path: "../cookbook-openstack-#{cookbook}"
  else
    cookbook "openstack-#{cookbook}", git: "https://git.openstack.org/openstack/cookbook-openstack-#{cookbook}"
  end
end

if Dir.exist?('../cookbook-openstackclient')
  cookbook 'openstackclient', path: '../cookbook-openstackclient'
else
  cookbook 'openstackclient', github: 'scassiba/cookbook-openstackclient'
end

cookbook 'statsd', github: 'librato/statsd-cookbook'
