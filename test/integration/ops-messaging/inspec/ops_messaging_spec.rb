describe port '5672' do
  it { should be_listening }
  its('addresses') { should include '127.0.0.1' }
end

describe service 'rabbitmq-server' do
  it { should be_running }
  it { should be_enabled }
end

describe command 'rabbitmqctl list_users' do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /admin\t\[administrator\]\n/ }
end

os_release = os.release.to_i
os_family = os.family

describe command 'rabbitmqctl list_vhosts' do
  its('exit_status') { should eq 0 }
  if os_release >= 8 && os_family == 'redhat'
    its('stdout') { should match %r{^Listing vhosts ...\nname\n/\n$} }
  else
    its('stdout') { should match %r{^Listing vhosts\n/\n$} }
  end
end
