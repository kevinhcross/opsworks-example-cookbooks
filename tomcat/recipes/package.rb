#
# Cookbook Name:: tomcat
# Recipe:: package
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Copyright 2010, Opscode, Inc.
# Copyright 2012, Bryan W. Berry
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# let's set the tomcat attributes to the ones that match the ubuntu
# packages, damn the FHS

version = node['tomcat']['version'].to_s
node.set["tomcat"]["user"] = "tomcat#{version}"
node.set["tomcat"]["group"] = "tomcat#{version}"
node.set["tomcat"]["home"] = "/usr/share/tomcat#{version}"
node.set["tomcat"]["base"] = "/var/lib/tomcat#{version}"
node.set["tomcat"]["config_dir"] = "/etc/tomcat#{version}"
config_dir = node["tomcat"]["config_dir"]
node.set["tomcat"]["log_dir"] = "/var/log/tomcat#{version}"
node.set["tomcat"]["tmp_dir"] = "/tmp/tomcat#{version}-tmp"
node.set["tomcat"]["work_dir"] = "/var/cache/tomcat#{version}"
node.set["tomcat"]["context_dir"] = "#{config_dir}/Catalina/localhost"
node.set["tomcat"]["webapp_dir"] = "/var/lib/tomcat#{version}/webapps"

# this recipe only supports debian or ubuntu
unless platform? ["debian", "ubuntu"]
  Chef::Application::fatal!("This recipe only supports Ubuntu or Debian")
end

tomcat_pkgs = [ "libtomcat#{version}-java", "tomcat#{version}", "tomcat#{version}-admin"]

execute "apt_update" do
 command "apt-get update"
 action :run
end

tomcat_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

service "tomcat" do
  service_name "tomcat#{version}"
  supports :restart => true, :reload => true, :status => true
  action :enable
end

cookbook_file "/usr/share/tomcat7/bin/catalina.sh" do
  source "catalina.sh"
  mode "0755"
  owner "root"
  group "root"
end

template "tomcat#{version}" do
  path "/etc/init.d/tomcat#{version}"
  source "tomcat.init.debian.erb"
  owner "root"
  group "root"
  mode "0774"
  variables( :name => "tomcat#{version}")
  #notifies :restart, resources(:service => "tomcat")
end

template "/etc/default/tomcat#{version}" do
  source "default_tomcat.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(:tomcat => node['tomcat'].to_hash)
  #notifies :restart, resources(:service => "tomcat")
end


template "/etc/tomcat#{version}/server.xml" do
  source "server.tomcat#{version}.xml.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(:tomcat => node['tomcat'].to_hash)
  #notifies :restart, resources(:service => "tomcat")
end

cookbook_file "/etc/tomcat#{version}/tomcat-users.xml" do
  source "tomcat-users.xml"
  mode "0644"
  owner "root"
  group "root"
end


# For some reason the packaged version of tomcat does not have the required jdbc jar so adding it here.
remote_file "/usr/share/tomcat7/lib/tomcat-jdbc.jar" do
  source "http://chefresources.edinburgh.ncrcoe.com/tomcat/apache-tomcat-7.0.26/lib/tomcat-jdbc.jar"
  backup false
  mode "0644"
  owner "root"
  group "root"
end

# Add a couple of database jars to the lib dir
remote_file "/usr/share/tomcat7/lib/postgresql.jar" do
  source "http://mull:8301/nexus/service/local/artifact/maven/redirect?r=central&g=postgresql&a=postgresql&v=9.1-901.jdbc4&e=jar"
  backup false
  mode "0644"
  owner "root"
  group "root"
end

remote_file "/usr/share/tomcat7/lib/hsqldb.jar" do
  source "http://mull:8301/nexus/service/local/artifact/maven/redirect?r=central&g=hsqldb&a=hsqldb&v=1.8.0.1&e=jar"
  backup false
  mode "0644"
  owner "root"
  group "root"
end

