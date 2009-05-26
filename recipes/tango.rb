namespace :passenger do
  desc "Restart Passenger"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Stop Passenger"
  task :stop, :roles => :app do
    run "touch #{current_path}/tmp/stop.txt"
  end

  desc "Start (or un-stop) Passenger"
  task :start, :roles => :app do
    run "rm -f #{current_path}/tmp/stop.txt"
  end
end

after 'deploy:setup', "tango:setup_passenger"
after 'deploy:setup', "tango:setup_logrotate"

after :deploy, "deploy:migrate"
after "deploy:migrate", "deploy:cleanup"
after :deploy, "passenger:restart"

deploy.task :start do
 # nothing
end 

deploy.task :restart do
 # nothing
end


# =============================================================================
#   Tango Setup, specific to my deployment environment
# =============================================================================

namespace :tango do

  desc "Stop the sphinx server"
  task :setup_passenger , :roles => :app do
    passenger_conf = <<-CMD
<VirtualHost *:80 >
  ServerName #{application}.com
  DocumentRoot #{current_path}/public
  PassengerHighPerformance on  
  <directory "#{current_path}/public">
    Order allow,deny
    Allow from all
  </directory>
</VirtualHost>
CMD
    run "echo '#{passenger_conf}' |sudo tee /etc/apache2/sites-available/#{application}.conf"
  end

  desc "Start the sphinx server" 
  task :setup_logrotate, :roles => :app do
    logrotate = <<-CMD
#{current_path}/log/*.log {
  daily
  missingok
  rotate 5
  compress
  delaycompress
  sharedscripts
  postrotate
    touch #{current_path}/tmp/restart.txt
  endscript
}
CMD
    run "echo '#{logrotate}' |sudo tee /etc/logrotate.d/#{application}"
  end

    
end