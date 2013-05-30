
directory node[:deploy][:ticketingstats][:deploy_to] do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

node[:deploy].each do |application, deploy|

  Chef::Log.info("Deploying #{application} to #{node[:deploy][:ticketingstats][:deploy_to]}")

  script "test_deploy_script" do
    interpreter "bash"
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
    echo "what about this one?" >> khc_deploy.log
    EOH
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    app application
    deploy_data deploy
  end
end
