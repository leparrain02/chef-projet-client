# # encoding: utf-8

# Inspec test for recipe tomcat::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe command('curl http://localhost:8080') do
  its('stdout') { should match(/Tomcat/) }
end

describe package('java-1.7.0-openjdk-devel') do
  it { should be_installed }
end

describe user('tomcat') do
  it { should exist }
  its('group') { should eq 'tomcat' }
end

describe file('/opt/tomcat') do
  it { should exist }
  it { should be_directory }
end

describe file('/opt/tomcat/apache-tomcat-8.0.44/conf') do
  it { should exist }
  it { should be_directory }
  its('group') { should eq 'tomcat' }
  it { should be_readable.by('group')}
  it { should be_writable.by('group')}
  it { should be_executable.by('group')}
end

%w( webapps work temp logs).each do |repertoire|
  describe file("/opt/tomcat/apache-tomcat-8.0.44/#{repertoire}") do
    it { should exist }
    it { should be_directory }
    it { should be_owned_by 'tomcat' }
  end
end
