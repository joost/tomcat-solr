#
# Cookbook Name:: solr
# Recipe:: default
#
# Copyright 2012, Example Com
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
include_recipe "tomcat-solr::service"

case node[:platform]
when "debian", "ubuntu"

    tomcat_group = "tomcat7"

    package "tomcat7" do
        action :install
    end

    # configuring tomcat
    template "/var/lib/tomcat7/conf/Catalina/localhost/solr.xml" do
        source "tomcat_solr.xml.erb"
        owner "root"
        group tomcat_group
        mode "0664"
    end

    # creating solr home and solr core
    directory "#{node[:solr][:home]}/#{node[:solr][:core_name]}" do
        owner "root"
        group tomcat_group
        mode "0777"
        action :create
        recursive true
    end

    directory "#{node[:solr][:home]}/#{node[:solr][:core_name]}/conf" do
        owner "root"
        group tomcat_group
        mode "0777"
        action :create
    end

    # configuring solr
    template "#{node[:solr][:home]}/solr.xml" do
        source "solr.xml.erb"
        owner "root"
        group "root"
        mode "0664" 
    end

    template "#{node[:solr][:home]}/#{node[:solr][:core_name]}/conf/solrconfig.xml" do
        source "solrconfig.xml.erb"
        owner "root"
        group "root"
        mode "0644"
    end

    template "#{node[:solr][:home]}/#{node[:solr][:core_name]}/conf/schema.xml" do
        source "schema.xml.erb"
        owner "root"
        group "root"
        mode "0644"
    end

    template "/etc/tomcat7/server.xml" do
      source "server.xml"
      owner "root"
      group tomcat_group
      mode "0644"
      notifies :restart, resources(:service => "tomcat7")
    end

    # download a binary release...
    remote_file "/tmp/apache-solr-4.0.0.tgz" do
      source "http://archive.apache.org/dist/lucene/solr/4.0.0/apache-solr-4.0.0.tgz"
      action :create_if_missing
    end

    # ...and extract solr.war for tomcat
    execute "extract" do
      command "tar xf apache-solr-4.0.0.tgz && cp apache-solr-4.0.0/example/webapps/solr.war /var/lib/tomcat7/webapps/solr.war"
      creates "/var/lib/tomcat7/webapps/solr.war"
      not_if { ::File.exists?("/var/lib/tomcat7/webapps/solr.war") }
      cwd "/tmp"
    end
end
