require 'chef/knife'
require 'fileutils'
require 'uri'
require "#{File.dirname(__FILE__)}/dengine_server_base"

class Chef
  class Knife
    class DengineServerGrow < Knife
      
      include Chef::Knife::DengineServerBase

      banner 'knife dengine server grow -e env -r role -f flavor -p platform'

      option :environment,
        :short => '-e SERVER_ENV',
        :long => '--environment SERVER_ENV',
        :description => "In which Environment the server has to be created"

      option :role,
        :short => '-r CHEF_ROLE',
        :long => '--role CHEF_ROLE',
        :description => "Which chef role to use. Run 'knife role list' for a list of roles."

      option :flavor,
        :short => '-f FLAVOR',
        :long => '--flavor FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine",
        :proc => Proc.new { |f| Chef::Config[:knife][:flavor] = f }

      option :platform,
        :short => '-p PLATFORM',
        :long => '--platform PLATFORM',
        :description => 'The platform/os the machine has to be created'


      def run

       env = config[:environment]
       role = config[:role]
       flavor = config[:flavor]
       platform = config[:platform]
       puts "#{env}"
       vpc = get_env(env)
       sg = get_security_group(env)
       chef_node_name = "#{role}-#{env}"

       puts ''
       puts "#{ui.color('rolename', :magenta)}   : #{role}"
       puts "#{ui.color('environment', :magenta)}: #{env}"
       puts "#{ui.color('flavor', :magenta)}     : #{flavor}"
       puts "#{ui.color('platform', :magenta)}   : #{platform}"
       puts ''

       puts "#{ui.color('Set back we are creating server for you with desired platform', :cyan)}  #{platform}"
       puts ''
       puts ''
         if platform == 'ubuntu'
           create = "knife ec2 server create -r role[#{role}] -I ami-8a9d5dea -f #{flavor} -S chef-coe --node-name #{chef_node_name} --ssh-user ubuntu --region us-west-2 --security-group-ids #{sg} --subnet #{vpc} --associate-public-ip"
         elsif platform == 'windows'
           create = "knife ec2 server create -r role[#{role}] -I ami-1562d075 -f #{flavor} \ -S chef-coe --node-name #{chef_node_name} --ebs-size 30 --region us-west-2 --security-group-ids sg-09f80971 --user-data /root/chef-repo/.chef/credentials/windows-script.ps1 --winrm-transport plaintext"
         else
           puts 'you have have not selected the proper OS'
         end

         @dr = '/root/chef-repo/.chef/server-create-scripts/'
         @fl = 'create.txt'

         if File.exist? File.expand_path(@dr + 'newservercreate.txt')
         else
           File.new(@fl.to_s, 'w+')
         end
         File.write(@fl.to_s, @create)

         puts "#{ui.color('COMMAND', :magenta)} : #{create}"
         #exec create
      end
    end
  end
end
