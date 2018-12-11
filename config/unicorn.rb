# set path to application
app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"
working_directory app_dir

# setting unicorn options
worker_processes 6
preload_app true
timeout 15

# setting up socket location
listen "#{shared_dir}/sockets/unicorn.sock", :backlog => 64

# setting up master pid location
pid "#{shared_dir}/pids/unicorn.pid"
