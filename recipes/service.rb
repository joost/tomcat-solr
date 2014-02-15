service "tomcat7" do
  supports :status => true, :restart => true, :start => true, :stop => true
  action :nothing
end
