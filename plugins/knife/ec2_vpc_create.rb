require 'chef/knife'
require "#{File.dirname(__FILE__)}/ec2_resource_base"
require "#{File.dirname(__FILE__)}/ec2_client_base"

class Chef
  class Knife
    class Ec2VpcCreate < Knife

      include Chef::Knife::Ec2ResourceBase
      include Chef::Knife::Ec2ClientBase

      banner 'knife ec2 vpc create CIDR-BLOCK VPC-NAME'

      def run
        unless name_args.size == 2
          show_usage
          Chef::Application.fatal! 'Wrong number of arguments'
        end

        vpc_name = name_args[1]
        cidrBlock = name_args[0]

        # puts ''
        # puts "#{ui.color('CIDR', :magenta)}     : #{cidrBlock}"
        # puts "#{ui.color('vpc_name', :magenta)} : #{vpc_name}"
        # puts ''

          # creation of VPC
          puts "#{ui.color('VPC creation has been started', :cyan)}"
          puts ''
          vpc = connection_resource.create_vpc({ cidr_block: "#{cidrBlock}" })
          vpc_id = "#{vpc.vpc_id}"
          vpc.create_tags({ tags: [{ key: 'Name', value: "#{vpc_name}" }]})
          puts "#{ui.color('VPC is created', :cyan)}"

          return vpc_id
      end
    end
  end
end

