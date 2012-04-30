# Execute commands on a remote server
# I know capistrano already does this
# This was abstracted from a more specific solution that we already had in place and I thought it was worth sharing
# 
# Usage:
#
#   r = RemoteRun.new("qa-d0","webadmit_etl")
#   r.commands << "source /etc/profile"
#   r.commands << "cd ~/current"
#   r.commands << "rake extractor:run cas=3 users=12550"
# 
#   r.execute
#
require 'net/ssh'
require 'net/ssh/gateway'
require 'yaml'
module Elsewhere
  
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
       Net::SSH.start(host, @user) do |ssh|
         execute_over_ssh(ssh,command)
       end
    end
    
    
    def execute
      run_me = @commands.join(" && ")
      output = []
      
      if @gateway_host
        gateway_wrapper.ssh(host, @user, {:forward_agent => true}) do |gateway|
          @hosts.uniq.each do |h|
            gateway.ssh(host, options[:gateway_user], {:forward_agent => true}) do |ssh|
              execute_over_ssh(ssh, run_me)
            end
          end
        end
      else
         @hosts.each{ |h| output << ssh_wrapper(h,run_me) }
      end
      
      output.flatten
    end
    
    def execute_over_ssh(ssh,command)
      stdout = ""
      ssh.exec!(command) do |channel,stream,data|
         case stream
         when :stderr
           raise RemoteRunError, data 
         else
           stdout << data 
         end
       end
       
       return stdout
    end

  end 
  
end

if __FILE__ == $0
  r = RemoteRun.new("wa-etl-q0","wa-current")
  r.commands << "LSOFs"
  puts r.execute
end
