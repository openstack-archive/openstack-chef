describe kernel_parameter 'net.ipv4.conf.all.rp_filter' do
  its('value') { should eq 0 }
end

describe kernel_parameter 'net.ipv4.conf.default.rp_filter' do
  its('value') { should eq 0 }
end

os_family = os.family

describe command 'openstack --version' do
  its('exit_status') { should eq 0 }
  if os_family == 'redhat'
    its('stderr') { should match /^openstack 3.16.[0-9]+$/ }
  else
    its('stdout') { should match /^openstack 3.16.[0-9]+$/ }
  end
end

if os.family == 'redhat'
  %w(
    centos-release-qemu-ev
    python
    python2-openstackclient
    python2-pip
    python2-setuptools
    python2-wheel
    python-devel
    python-virtualenv
  ).each do |pkg|
    describe package pkg do
      it { should be_installed }
    end
  end

  describe yum.repo('RDO-rocky') do
    it { should exist }
    it { should be_enabled }
  end

  describe yum.repo('RDO-rocky-deps') do
    it { should_not exist }
    it { should_not be_enabled }
  end
else
  %w(
    python3
    python3-dev
    python3-openstackclient
    python3-pip
    python3-setuptools
    python3-virtualenv
    python3-wheel
    virtualenv
  ).each do |pkg|
    describe package pkg do
      it { should be_installed }
    end
  end

  # apt InSpec resource is not working properly
  describe file '/etc/apt/sources.list.d/openstack-ppa.list' do
    its('content') { should include 'http://ubuntu-cloud.archive.canonical.com/ubuntu bionic-updates/rocky main' }
  end

  describe file '/etc/apt/sources.list.d/openstack-ppa-proposed.list' do
    it { should_not exist }
  end
end
