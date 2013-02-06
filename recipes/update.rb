#
# Cookbook Name:: monitis
# Recipe:: update
# Author:: 
#
# Copyright 2012, Monitis, Inc
#

if platform?("debian", "ubuntu", "centos", "fedora", "suse", "redhat")

package "wget" do
  action :install
end

package "tar" do
  action :install
end

package "#{node[:MONITIS][:LIBSSL]}" do
  action :install
end

execute "stop_monitis" do
   cwd "#{node[:MONITIS][:INSTALLDIR]}/monitis"
   command "./monitis.sh stop"
   action :run
end

bash "backup_config" do
  code <<-EOF
        cp #{node[:MONITIS][:INSTALLDIR]}/monitis/etc/monitis.conf /tmp/
  EOF
end


execute "remove_monitis" do
   cwd "/tmp/"
   command "rm -rf #{node[:MONITIS][:INSTALLDIR]}/monitis"
   action :run
end

arch = node[:kernel][:machine]

if "#{arch}" == "x86_64"

tarball = "#{node[:MONITIS][:TARBALL_64]}"

execute "wget" do
  tarball_url = "#{node[:MONITIS][:TARBALL_URL_64]}"
  cwd "/tmp"
  command "wget '#{tarball_url}' -O /tmp/#{tarball}"
  creates "/tmp/#{tarball}"
  action :run
end

else 

tarball = "#{node[:MONITIS][:TARBALL_32]}"

execute "wget" do
  tarball_url = "#{node[:MONITIS][:TARBALL_URL_32]}"
  cwd "/tmp"
  command "wget '#{tarball_url}' -O /tmp/#{tarball}"
  creates "/tmp/#{tarball}"
  action :run
end

end

execute "tar" do
  user "root"
  group "root"
  installation_dir = "#{node[:MONITIS][:INSTALLDIR]}"
  cwd installation_dir
  command "tar -zxf /tmp/#{tarball}"
  creates installation_dir + "/monitis"
  action :run
end

execute "remove_tarball" do
   cwd "/tmp/"
   command "rm -rf #{tarball}"
   action :run
end

template "#{node[:MONITIS][:INSTALLDIR]}/monitis/etc/monitis.conf" do
  source "monitis.conf_upd.erb"
  mode "0644"
end

bash "update_agentname" do
  code <<-EOF
	AGENTNAMEOLD=`cat /tmp/monitis.conf| grep AGENTNAME|awk '{print $2}'`
        echo "AGENTNAME	$AGENTNAMEOLD" >> #{node[:MONITIS][:INSTALLDIR]}/monitis/etc/monitis.conf
  EOF
end

execute "start_monitis" do
   cwd "#{node[:MONITIS][:INSTALLDIR]}/monitis"
   command "./monitis.sh start"
   action :run
end

end

if platform?("windows")

arch = node[:kernel][:machine]
tarball = "#{node[:MONITIS][:TARBALL]}"
tarball_url = "#{node[:MONITIS][:TARBALL_URL]}"
dst = "c:/Windows/Temp/#{tarball}"
exe = "c:/Windows/Temp/MonitisAgentSetup.exe"

if "#{arch}" == "x86_64"

template "C:/Windows/Temp/uninstall_x64.bat" do
  source "uninstall_x64.bat.erb"
#  mode "0644"
end

bat = "C:/Windows/Temp/uninstall_x64.bat"

else

template "C:/Windows/Temp/uninstall_x32.bat" do
  source "uninstall_x32.bat.erb"
#  mode "0644"
end

bat = "C:/Windows/Temp/uninstall_x32.bat"

end

execute "uninstall" do
#  only_if {File.exists?('')}
#  cwd "#{path}"
  command "#{bat}"
end

execute "remove_bat" do
  command "rm -r #{bat}"
end

remote_file "#{dst}" do
  source "#{tarball_url}"
end
 
monitis_zipfile dst do
#  force true
  path "c:/Windows/Temp/"
  source "#{dst}"
  action :unzip
end

execute "install #{exe}" do
  command "#{exe} /S"
end

execute "registry" do
  command "regedit /s c:/Windows/Temp/agent.reg"
end

if "#{arch}" == "x86_64"

monitis_registry 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Monitis.com\Monitis\Agent' do
  values 'E-Mail' => node[:MONITIS][:USEREMAIL]
end

monitis_registry 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Monitis.com\Monitis\Agent' do
  values 'Password' => node[:MONITIS][:PASSWORD]
end

else

monitis_registry 'HKEY_LOCAL_MACHINE\SOFTWARE\Monitis.com\Monitis\Agent' do
  values 'E-Mail' => node[:MONITIS][:USEREMAIL]
end

monitis_registry 'HKEY_LOCAL_MACHINE\SOFTWARE\Monitis.com\Monitis\Agent' do
  values 'Password' => node[:MONITIS][:PASSWORD]
end

end

execute "remove_tarball" do
   cwd "c:/Windows/Temp/"
   command "rm -f #{dst}"
   action :run
end

execute "remove_exe" do
   cwd "c:/Windows/Temp/"
   command "rm -f #{exe}"
   action :run
end

execute "remove_registry" do
   cwd "c:/Windows/Temp/"
   command "rm -f agent.reg"
   action :run
end

execute "sleep_5" do
  command "ping -n 10 localhost> nul"
end

execute "kill_process" do
  command 'taskkill /F /IM controller.exe'
end

execute "stop_service" do
  command 'net stop "Monitis Smart Agent" /y'
end

execute "start_service" do
  command 'net start "Monitis Smart Agent" /y'
end

end

