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
    cookbook "openstack-#{cookbook}",
    git: "https://opendev.org/openstack/cookbook-openstack-#{cookbook}",
    branch: 'stable/rocky'
  end
end

if Dir.exist?('../cookbook-openstackclient')
  cookbook 'openstackclient', path: '../cookbook-openstackclient'
else
  cookbook 'openstackclient',
  git: 'https://opendev.org/openstack/cookbook-openstackclient',
  branch: 'stable/rocky'
end

cookbook 'openstack_test', path: 'test/cookbooks/openstack_test'
cookbook 'statsd', github: 'librato/statsd-cookbook'
