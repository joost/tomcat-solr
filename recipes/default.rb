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
    solr_version = node[:solr][:version]

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
    remote_file "/tmp/solr-#{solr_version}.tgz" do
      filename = "solr-#{solr_version}.tgz"
      filename = "apache-#{filename}" if solr_version.to_f < 4.1 ? # Older versions have 'apache-' in the name
      source "http://archive.apache.org/dist/lucene/solr/#{solr_version}/#{filename}"
      action :create_if_missing
    end

    # ...and extract solr.war for tomcat
    execute "extract" do
      command "tar xf solr-#{solr_version}.tgz && cp solr-#{solr_version}/example/webapps/solr.war /var/lib/tomcat7/webapps/solr.war"
      creates "/var/lib/tomcat7/webapps/solr.war"
      not_if { ::File.exists?("/var/lib/tomcat7/webapps/solr.war") }
      cwd "/tmp"
    end

    # See: https://wiki.apache.org/solr/SolrLogging#Using_the_example_logging_setup_in_containers_other_than_Jetty
    # sudo cp /tmp/solr-4.6.1/example/lib/ext/* /usr/share/tomcat7/lib/
    # sudo cp /tmp/solr-4.6.1/example/resources/log4j.properties /usr/share/tomcat7/lib/

end
