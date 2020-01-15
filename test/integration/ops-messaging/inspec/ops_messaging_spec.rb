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

describe command 'rabbitmqctl list_vhosts' do
  its('exit_status') { should eq 0 }
  its('stdout') { should match %r{^Listing vhosts\n/\n$} }
end
