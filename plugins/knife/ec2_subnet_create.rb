require 'chef/knife'
require "#{File.dirname(__FILE__)}/ec2_resource_base"

class Chef
  class Knife
    class Ec2SubnetCreate < Knife

      include Chef::Knife::Ec2ResourceBase
 
      banner 'knife ec2 subnet create TYPE(private/public) CIDR-BLOCK SUBNET-NAME VPC-ID'

      def run
        unless name_args.size == 4
          show_usage
          Chef::Application.fatal! 'Wrong number of arguments'
        end

        type = name_args[0]
        cidrBlock = name_args[1]
        subnet_name = name_args[2]
        vpc_id = name_args[3] 

        #puts ''
        #puts "#{ui.color('Type', :magenta)}       : #{type}"
        #puts "#{ui.color('CIDR', :magenta)}       : #{cidrBlock}"
        #puts "#{ui.color('Subnet Name', :magenta)}: #{subnet_name}"
        #puts "#{ui.color('VPC-id', :magenta)}     : #{vpc_id}"
        #puts ''

          # creation of subnet
          puts "#{ui.color('subnet creation has been started', :cyan)}"
          subnet = connection_resource.create_subnet({vpc_id: "#{vpc_id}", cidr_block: "#{cidrBlock}"})
          subnet.create_tags({ tags: [{ key: 'Name', value: "#{subnet_name}" }]})
          subnet_id = subnet.id
          puts "."
          puts "."
          puts "#{ui.color('subnet creation is finished', :cyan)}"
          puts ''

          if type == "public"
            # creation of internet gateway
            # Chef::Log.debug 'Creating public IGW'
            puts "#{ui.color('Creating IGW for the subnet as it is public subnet', :cyan)}"
            igw = connection_resource.create_internet_gateway
            igw.create_tags({ tags: [{ key: 'Name', value: "#{subnet_name}" }]})
            igw.attach_to_vpc(vpc_id: "#{vpc_id}")
            gate_way_id = igw.id
            puts "."
            puts "."
            puts "#{ui.color('IGW creation is complete', :cyan)}"
            puts ''
            # creation of route table
            # Chef::Log.debug 'Creating public route tabel'
            puts "#{ui.color('creating route table for the VPC', :cyan)}"
            puts "."
            table = connection_resource.create_route_table({ vpc_id: "#{vpc_id}"})
            route_table_id = table.id
            table.create_tags({ tags: [{ key: 'Name', value: "#{subnet_name}" }]})
            # Chef::Log.debug 'Creating public route'
            puts "#{ui.color('Writing routes for the route table', :cyan)}"
            table.create_route({ destination_cidr_block: '0.0.0.0/0', gateway_id: "#{gate_way_id}"})
            # Chef::Log.debug 'Associating route table with subnet'
            puts "."
            puts "#{ui.color('Attaching route table to the subnet', :cyan)}"
            table.associate_with_subnet({ subnet_id: "#{subnet_id}"})
            puts ''

          else
            puts "#{ui.color('you have selected the subnet to be created as private and have we have created the same', :magenta)}"
          end

          #printing the details of the resources created
         # puts "#{ui.color('Here are the details of the resources created', :cyan)}"
         # puts ""
         # puts "#{ui.color('subnet_id', :magenta)}     : #{subnet_id}"
         # puts "#{ui.color('igw_id', :magenta)}        : #{gate_way_id}"
         # puts "#{ui.color('route_table_id', :magenta)}: #{route_table_id}"
         # puts ""
	 return subnet_id	
      end
    end
  end
end
