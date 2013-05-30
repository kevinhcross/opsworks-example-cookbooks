node[:deploy].each do |app_name, deploy|

  script "test_deploy_script" do
    interpreter "bash"
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
    echo "does this message appear?" >> khc_deploy.log
    EOH
  end

end
