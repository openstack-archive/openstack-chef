describe port '3306' do
  it { should be_listening }
  its('addresses') { should include '127.0.0.1' }
end

describe service 'mysql' do
  it { should be_running }
  it { should be_enabled }
end

my_cnf = os.family == 'redhat' ? '/etc/my.cnf.d/openstack.cnf' : '/etc/mysql/conf.d/openstack.cnf'

describe mysql_conf(my_cnf).params('mysqld') do
  its('default-storage-engine') { should eq 'InnoDB' }
  its('innodb_autoinc_lock_mode') { should eq '1' }
  its('innodb_file_per_table') { should eq 'OFF' }
  its('innodb_thread_concurrency') { should eq '0' }
  its('innodb_commit_concurrency') { should eq '0' }
  its('innodb_read_io_threads') { should eq '4' }
  its('innodb_flush_log_at_trx_commit') { should eq '1' }
  its('innodb_buffer_pool_size') { should eq '134217728' }
  its('innodb_log_file_size') { should eq '5242880' }
  its('innodb_log_buffer_size') { should eq '8388608' }
  its('character-set-server') { should eq 'latin1' }
  its('query_cache_size') { should eq '0' }
  its('max_connections') { should eq '307' }
end

describe mysql_session('root', 'mypass', '127.0.0.1').query('show databases;') do
  %w(
    ceilometer
    cinder
    designate
    glance
    gnocchi
    heat
    horizon
    ironic
    keystone
    neutron
    nova
    nova_api
    nova_cell0
  ).each do |db|
    its('stdout') { should include db }
  end
end
