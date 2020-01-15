openrc = 'bash -c "source /root/openrc && '

%w(
  9696
  6633
).each do |p|
  describe port p do
    it { should be_listening }
    its('addresses') { should include '127.0.0.1' }
  end
end

%w(
  neutron-dhcp-agent
  neutron-l3-agent
  neutron-metadata-agent
  neutron-openvswitch-agent
  neutron-server
).each do |s|
  describe service s do
    it { should be_enabled }
    it { should be_running }
  end
end

describe command "#{openrc} openstack network show local_net -f shell -c admin_state_up -c status\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should include 'admin_state_up="UP"' }
  its('stdout') { should include 'status="ACTIVE"' }
end

describe command "#{openrc} openstack subnet show local_subnet -f shell -c enable_dhcp -c cidr -c allocation_pools\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should include 'allocation_pools="192.168.180.2-192.168.180.254"' }
  its('stdout') { should include 'cidr="192.168.180.0/24"' }
  its('stdout') { should include 'enable_dhcp="True"' }
end

describe command "#{openrc} openstack user list -f value -c Name\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^neutron$/ }
end

describe command "#{openrc} openstack service list -f value -c Name -c Type\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^neutron network$/ }
end

describe command "#{openrc} openstack endpoint list -f value -c 'Service Name' -c 'Service Type' -c Enabled -c Interface -c URL\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match %r{neutron network True public http://127.0.0.1:9696} }
  its('stdout') { should match %r{neutron network True internal http://127.0.0.1:9696} }
end

describe command "#{openrc} openstack network agent list -f value -c Binary -c State -c Alive\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^:-\) UP neutron-dhcp-agent$/ }
  its('stdout') { should match /^:-\) UP neutron-metadata-agent$/ }
  its('stdout') { should match /^:-\) UP neutron-l3-agent$/ }
  its('stdout') { should match /^:-\) UP neutron-openvswitch-agent$/ }
end

describe command "#{openrc} openstack extension list --network -f value -c Alias\"" do
  its('exit_status') { should eq 0 }
  %w(
    address-scope
    agent
    allowed-address-pairs
    auto-allocated-topology
    availability_zone
    availability_zone_filter
    binding
    binding-extended
    default-subnetpools
    dhcp_agent_scheduler
    dvr
    empty-string-filtering
    external-net
    ext-gw-mode
    extra_dhcp_opt
    extraroute
    filter-validation
    fip-port-details
    flavors
    ip-substring-filtering
    l3_agent_scheduler
    l3-flavors
    l3-ha
    multi-provider
    net-mtu
    net-mtu-writable
    network_availability_zone
    network-ip-availability
    pagination
    port-mac-address-regenerate
    port-security-groups-filtering
    project-id
    provider
    quota_details
    quotas
    rbac-policies
    revision-if-match
    router
    router_availability_zone
    security-group
    service-type
    sorting
    standard-attr-description
    standard-attr-revisions
    standard-attr-tag
    standard-attr-timestamp
    subnet_allocation
    subnet-service-types
  ).each do |ext|
    its('stdout') { should match /^#{ext}$/ }
  end
end

describe command 'ovs-vsctl show' do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /Manager "ptcp:6640:127.0.0.1"/ }
  its('stdout') { should match /is_connected: true/ }
end
