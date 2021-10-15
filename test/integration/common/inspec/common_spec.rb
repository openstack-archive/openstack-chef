describe kernel_parameter 'net.ipv4.conf.all.rp_filter' do
  its('value') { should eq 0 }
end

describe kernel_parameter 'net.ipv4.conf.default.rp_filter' do
  its('value') { should eq 0 }
end

os_family = os.family
os_release = os.release.to_i

describe command 'openstack --version' do
  its('exit_status') { should eq 0 }
  # RHEL sends output to stderr while Ubuntu sends it to stdout
  if os_family == 'redhat' && os_release == 7
    its('stderr') { should match /^openstack 4.0.[0-9]+$/ }
  else
    its('stdout') { should match /^openstack 4.0.[0-9]+$/ }
  end
end

if os.family == 'redhat'
  if os_release >= 8
    %w(
      python3-pip
      python3-setuptools
      python3-virtualenv
      python3-wheel
      python36
      python36-devel
    ).each do |pkg|
      describe package pkg do
        it { should be_installed }
      end
    end
  else
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
  end

  describe yum.repo('RDO-train') do
    it { should exist }
    it { should be_enabled }
  end

  describe yum.repo('RDO-train-deps') do
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
    its('content') { should include 'http://ubuntu-cloud.archive.canonical.com/ubuntu bionic-updates/train main' }
  end

  describe file '/etc/apt/sources.list.d/openstack-ppa-proposed.list' do
    it { should_not exist }
  end
end
