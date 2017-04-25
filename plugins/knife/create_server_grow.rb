require 'chef/knife'
require 'fileutils'
require 'uri'
require "#{File.dirname(__FILE__)}/create_server_base"

class Chef
  class Knife
    class CreateServerGrow < Knife

      include Chef::Knife::CreateServerBase

      banner 'knife create server grow ROLE-NAME ENV FLAVOR PLATFORM'

      def run
       unless name_args.size == 4
         show_usage
         Chef::Application.fatal! 'Wrong number of arguments'
       end

       rolename = name_args[0]
       env = name_args[1]
       tiervalue = name_args[2]
       os = name_args[3]

       vpc = set_env(env)
       chef_node_name = "#{rolename}-#{env}"

       puts ''
       puts "#{ui.color('rolename', :magenta)}   : #{rolename}"
       puts "#{ui.color('environment', :magenta)}: #{env}"
       puts "#{ui.color('flavor', :magenta)}     : #{tiervalue}"
       puts "#{ui.color('platform', :magenta)}   : #{os}"
       puts ''

       puts "#{ui.color('Set back we are creating server for you with desired platform', :cyan)}  #{os}"
       puts ''
       puts ''
         if os == 'ubuntu'
           create = "knife ec2 server create -r role[#{rolename}] -I ami-8a9d5dea -f #{tiervalue} -S chef-coe --node-name #{chef_node_name} --ssh-user ubuntu --region us-west-2 --security-group-ids sg-f5833d8e --subnet #{vpc} --associate-public-ip"
         elsif os == 'windows'
           create = "knife ec2 server create -r role[#{rolename}] -I ami-1562d075 -f #{tiervalue} -S chef-coe --node-name #{chef_node_name} --ebs-size 30 --region us-west-2 --security-group-ids sg-29996952 --user-data /root/chef-repo/.chef/credentials/windows-script.ps1 --winrm-transport plaintext"
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
         exec create
      end
    end
  end
end

