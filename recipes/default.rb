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
    # template "/var/lib/tomcat7/conf/Catalina/localhost/solr.xml" do
    #     source "tomcat_solr.xml.erb"
    #     owner "root"
    #     group tomcat_group
    #     mode "0664"
    # end

    # creating solr home and solr core
    # directory "#{node[:solr][:home]}/#{node[:solr][:core_name]}" do
    #     owner "root"
    #     group tomcat_group
    #     mode "0777"
    #     action :create
    #     recursive true
    # end

    # directory "#{node[:solr][:home]}/#{node[:solr][:core_name]}/conf" do
    #     owner "root"
    #     group tomcat_group
    #     mode "0777"
    #     action :create
    # end

    # # configuring solr
    # template "#{node[:solr][:home]}/solr.xml" do
    #     source "solr.xml.erb"
    #     owner "root"
    #     group "root"
    #     mode "0664"
    # end

    # template "#{node[:solr][:home]}/#{node[:solr][:core_name]}/conf/solrconfig.xml" do
    #     source "solrconfig.xml.erb"
    #     owner "root"
    #     group "root"
    #     mode "0644"
    # end

    # template "#{node[:solr][:home]}/#{node[:solr][:core_name]}/conf/schema.xml" do
    #     source "schema.xml.erb"
    #     owner "root"
    #     group "root"
    #     mode "0644"
    # end

    directory "#{node[:solr][:home]}/example/solr" do
        owner "root"
        group tomcat_group
        mode "0777"
        action :create
        recursive true
    end

    template "/etc/tomcat7/server.xml" do
      source "server.xml"
      owner "root"
      group tomcat_group
      mode "0644"
      notifies :restart, resources(:service => "tomcat7")
    end

    solr_filename = "solr-#{solr_version}"
    solr_filename = "apache-#{solr_filename}" if solr_version.to_f < 4.1 # Older versions have 'apache-' in the name

    # download a binary release...
    remote_file "/tmp/#{solr_filename}.tgz" do
      source "http://archive.apache.org/dist/lucene/solr/#{solr_version}/#{solr_filename}.tgz"
      action :create_if_missing
    end

    # ...and extract solr.war for tomcat
    execute "extract" do
      # See: https://wiki.apache.org/solr/SolrTomcat
      command "tar xf #{solr_filename}.tgz && cp #{solr_filename}/example/webapps/solr.war #{node[:solr][:home]}/example/solr/solr.war"
      creates "#{node[:solr][:home]}/example/solr/solr.war"
      not_if { ::File.exists?("#{node[:solr][:home]}/example/solr/solr.war") }
      cwd "/tmp"
    end

    # See: https://wiki.apache.org/solr/SolrLogging#Using_the_example_logging_setup_in_containers_other_than_Jetty
    # sudo cp /tmp/solr-4.6.1/example/lib/ext/* /usr/share/tomcat7/lib/
    # sudo cp /tmp/solr-4.6.1/example/resources/log4j.properties /usr/share/tomcat7/lib/

end
