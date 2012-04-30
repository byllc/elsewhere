# Execute commands on a remote server
# I know capistrano already does this
# This was abstracted from a more specific solution that we already had in place and I thought it was worth sharing
# 
# Usage:
#
#   r = RemoteRun.new("hostname","username")
#   r.commands << "source /etc/profile"
#   r.commands << "cd ~/current"
#   r.commands << "rake extractor:run cas=3 users=12550"
# 
#   r.execute
#
require 'net/ssh'
require 'net/ssh/gateway'
require 'yaml'
class RemoteRun  
  
  #TODO: move to remote_run/exceptions.rb when we gemify this
  class RemoteRunError < StandardError; end
  
  attr_accessor :hosts, :gateway_address, :gateway_user, :commands
  
  def initialize(hosts,user, options={})
    @hosts        = [hosts].flatten #accept a single host or an array of hosts 
    @gateway_address = options[:gateway_address]
    @gateway_user = options[:gateway_user] 
    @user         = user
    @commands     = []
  end
  
  #expects the config file to be formatted as yaml as follows
  #environment:
  #  group:
  #    user: username
  #    host: hostname
  def self.initialize_from_config(config_file,environment,group,options={})
    config_file = YAML.load_file(config_file)
    env_config = config_file[environment][group]
    options[:gateway_address] ||= env_config["gateway"]["host"] unless env_config["gateway"].nil?
    options[:gateway_user]    ||= env_config["gateway"]["user"] unless env_config["gateway"].nil?
    new(env_config["host"],env_config["user"],options)
  end 
  
  #gateway wrapper when a gateway is specified
  def gateway_wrapper
    @gateway_host ||= if(@gateway_addr && @gateway_user)
      Net::SSH::Gateway.new(@gateway_addr, @gateway_user, {:forward_agent => true})
    else
      nil
    end
  end
  
  def ssh_wrapper(host,command)
     output = nil
     Net::SSH.start(host, @user) do |ssh|
       output = execute_over_ssh(ssh,command)
     end
     output
  end

  # Run all of the items in the commands hash
  # The joined_by paramenter dictates how to join the commands before execution
  # Returns: A hash of the responses for each specified host 
  def execute(joined_by = " && ") 
    run_me = @commands.join(joined_by)
    output = {}
    
    if @gateway_host
      gateway_wrapper.ssh(host, @user, {:forward_agent => true}) do |gateway|
        @hosts.uniq.each do |h|
          gateway.ssh(host, options[:gateway_user], {:forward_agent => true}) do |ssh|
            output[h] = execute_over_ssh(ssh, run_me)
          end
        end
      end
    else
       @hosts.uniq.each{ |h| output[h] = ssh_wrapper(h,run_me) }
    end
    
    return output
  end

  #execute the given commend for the Net::SSH instance 
  #return the data or raise an error depending on which stream is returned
  def execute_over_ssh(ssh,command)
    stdout = ""
    ssh.exec!(command) do |channel,stream,data|
       case stream
       when :stderr
         raise RemoteRunError, data 
       else
         stdout = data 
       end
     end
     return stdout
  end
  
  
end


if __FILE__ == $0
  host = ""
  user = ""
  r = RemoteRun.new(host,user)
  r.commands << "ls"
  puts r.execute
end
