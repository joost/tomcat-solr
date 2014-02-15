Description
===========
Configures and deploys Solr 4.0.0 on Tomcat 7.

Requirements
============

Platform:

Debian, Ubuntu (OpenJDK, Oracle)
CentOS 6+, Red Hat 6+, Fedora (OpenJDK, Oracle)
The following Opscode cookbooks are dependencies:

java

Attributes
==========

node['solr']['port'] - The port used by Solr server (Tomcat 7 HTTP connector). Default: 8893.    
node['solr']['home'] - Directory that will hold Solr configuration and data storage. Default: /opt/solr     
node['solr']['data_dir'] - Directory to hold indexes data. Default: solr_home/data.     
node['solr']['core_name'] - Name of the running Solr core

Usage
=====

Simply include the recipe where you want Solr server running.
