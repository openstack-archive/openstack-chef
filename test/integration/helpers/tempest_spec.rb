describe command '/opt/tempest-venv/tempest.sh' do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^ - Failed: 0$/ }
end
