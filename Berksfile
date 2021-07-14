source 'https://supermarket.chef.io'

solver :ruby, :required

%w(
  bare-metal
  block-storage
  common
  compute
  dashboard
  dns
  identity
  image
  integration-test
  network
  ops-database
  ops-messaging
  orchestration
  telemetry
).each do |cookbook|
  if Dir.exist?("../cookbook-openstack-#{cookbook}")
    cookbook "openstack-#{cookbook}", path: "../cookbook-openstack-#{cookbook}"
  else
    cookbook "openstack-#{cookbook}", git: "https://opendev.org/openstack/cookbook-openstack-#{cookbook}",
      branch: 'stable/stein'
  end
end

if Dir.exist?('../cookbook-openstackclient')
  cookbook 'openstackclient', path: '../cookbook-openstackclient'
else
  cookbook 'openstackclient', git: 'https://opendev.org/openstack/cookbook-openstackclient',
    branch: 'stable/stein'
end

cookbook 'openstack_test', path: 'test/cookbooks/openstack_test'
cookbook 'statsd', github: 'librato/statsd-cookbook'
# TODO(ramereth): Remove after this PR is merged
# https://github.com/joyofhex/cookbook-bind/pull/60
cookbook 'bind', github: 'joyofhex/cookbook-bind'
