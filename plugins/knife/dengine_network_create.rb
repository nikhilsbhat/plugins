require 'chef/knife'
require "#{File.dirname(__FILE__)}/ec2_vpc_create"
require "#{File.dirname(__FILE__)}/ec2_subnet_create"
require "#{File.dirname(__FILE__)}/ec2_security_create"

module Engine
  class DengineNetworkCreate < Chef::Knife

    deps do
      Chef::Knife::Ec2VpcCreate.load_deps
      Chef::Knife::Ec2SubnetCreate.load_deps
      Chef::Knife::Ec2SecurityCreate.load_deps
    end

    banner 'knife dengine network create ENV'

    def run

    unless name_args.size == 1
      show_usage
        Chef::Application.fatal! 'Wrong number of arguments'
    end

    name = name_args[0]

    #name = 'PROD'
    vpc_cidr = '192.168.0.0/16'
    type = 'public'
    sub_cidr = '192.168.10.0/24'

    #creation of vpc
    ec2_vpc = Chef::Knife::Ec2VpcCreate.new
    ec2_vpc.name_args = ["#{vpc_cidr}","#{name}"]
    ec2_vpc_out = ec2_vpc.run

    #creation of subnet
    ec2_subnet = Chef::Knife::Ec2SubnetCreate.new
    ec2_subnet.name_args = ["#{type}","#{sub_cidr}","#{name}","#{ec2_vpc_out}"]
    ec2_subnet_out = ec2_subnet.run

    #creation of security group
    ec2_security = Chef::Knife::Ec2SecurityCreate.new
    ec2_security.name_args = ["#{name}","#{ec2_vpc_out}"]
    ec2_security_out = ec2_security.run

	#creating and adding data to data_bag
	users = Chef::DataBag.new
        users.name("#{name}")
        users.create	
        data = {
               'id' => "#{name}",
               'VPD-ID' => "#{ec2_vpc_out}",
               'SUBNET-ID' => "#{ec2_subnet_out}",
               'SECURITY-ID' => "#{ec2_security_out}"
               }
        databag_item = Chef::DataBagItem.new
        databag_item.data_bag("#{name}")
        databag_item.raw_data = data
        databag_item.save 
			
    #printing resource details
    puts "#{ec2_vpc_out}"
    puts "#{ec2_subnet_out}"
    puts "#{ec2_security_out}"

    end
  end
end
