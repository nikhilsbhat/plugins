require 'chef/knife'
require "#{File.dirname(__FILE__)}/ec2_resource_base"

class Chef
  class Knife
    class Ec2VpcCreate < Knife

      include Chef::Knife::Ec2ResourceBase

      banner 'knife ec2 vpc create CIDR-BLOCK VPC-NAME'

      def run
        unless name_args.size == 2
          show_usage
          Chef::Application.fatal! 'Wrong number of arguments'
        end

        vpc_name = name_args[1]
        cidrBlock = name_args[0]

        puts ''
        puts "#{ui.color('CIDR', :magenta)}     : #{cidrBlock}"
        puts "#{ui.color('vpc_name', :magenta)} : #{vpc_name}"
        puts ''

        option = ui.ask_question( "The above mentioned are the details for the VPC creation, would you like to proceed...?  [y/n]", opts = {:default => 'n'})

        if option == "y"

          puts "#{ui.color('VPC creation has been started', :cyan)}"
          puts ''
          vpc = connection.create_vpc({ cidr_block: "#{cidrBlock}" })
          vpc_id = "#{vpc.vpc_id}"
          vpc.create_tags({ tags: [{ key: 'Name', value: "#{vpc_name}" }]})
          puts "#{ui.color('VPC is created', :cyan)}"

          puts ''
          puts "#{ui.color('The details of the resource that was created', :cyan)}"
          puts "#{ui.color('vpc-id', :magenta)}   : #{vpc_id}"
          puts ''
        else
          puts "#{ui.color('...You have opted to move out of image creation...', :cyan)}"
        end
      end
    end
  end
end
