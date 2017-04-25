require 'chef/knife/ec2_base'
require 'chef/knife'
#include Fog::Compute
class Chef
  class Knife
    class Ec2Test < Knife

      banner 'knife ec2 test CIDR-BLOCK VPC-NAME'

      option :yes,
        :short => 'y',
        :long => 'yes',
        :description => 'selecting yes for the operation.'

      option :no,
        :short => 'n',
        :long => 'no',
        :description => 'selecting no for operation.'

      def run
        unless name_args.size == 1 
          show_usage
          Chef::Application.fatal! 'Wrong number of arguments'
        end

        action = name_args[0]
        test = ui.ask_question( "Do you want the subent to be created...?", opts = {:default => 'no'})
        if test == 'yes'
          puts 'selected yes'
        elsif test == 'no'
          puts 'selected no'
        else 
          puts 'not selected anything'
          puts "#{test}"
        end
          type = "private"
          cidrBlock = "192.168.0.0/16"
          subnet_name = "My Subnet"
          vpc_id = "vpc-id12345"
          puts '.'
          puts '.'
          puts "#{ui.color('Type', :magenta)}       : #{type}"
          puts "#{ui.color('CIDR', :magenta)}       : #{cidrBlock}"
          puts "#{ui.color('Subnet Name', :magenta)}: #{subnet_name}"
          puts "#{ui.color('VPC-id', :magenta)}     : #{vpc_id}"
        
        try = ui.ask_question( "Is the details you mentioned correct do you want yo proceed...?", opts = { })
      
      end
    end
  end
end
