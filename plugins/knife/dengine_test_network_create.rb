require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_interface"
require "#{File.dirname(__FILE__)}/base/dengine_aws_interface"

module Engine
  class DengineTestNetworkCreate < Chef::Knife

    banner 'knife dengine test network create (options)'

    option :name,
      :short => '-n NETWORK_NAME',
      :long => '--name NETWORK_NAME',
      :description => "The name of the network that has to be created"

    option :resource_group,
      :short => '-r RESOURCE_GROUP_NAME',
      :long => '--resource-group-name RESOURCE_GROUP_NAME',
      :description => "The name of Resource group in which the network that has to be created",
      :default => "Dengine"

    option :cloud,
      :long => '--cloud CLOUD_PROVIDER_NAME',
      :description => "The name of the cloud provider for ex: aws, azure, google, openstack etc"

    option :vpc_cidr_block,
      :long => '--vpc-cidr-block VPC_CIDR_BLOCK',
      :description => "The CIDR block to construct your VPC, ex: 192.168.0.0/16",
      :default => ['192.168.0.0/16'],
      :proc => Proc.new { |i| i.split(/,/) }

    option :subnet_cidr_block,
      :long => '--subnet-cidr-block SUBNET_CIDR_BLOCK',
      :description => "The CIDR block to construct your SUBNET, ex: 192.168.0.0/24",
      :default => ['192.168.0.0/24'],
      :proc => Proc.new { |i| i.split(/,/) }


    def run

      name = config[:name]

      if config[:cloud] == "aws"
         @client = DengineAwsInterface.new
      elsif (config[:cloud] == "azure")
         @client = DengineAzureInterface.new
      elsif (config[:cloud] == "google")
         puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
         exit
         @client = ''
      elsif (config[:cloud] == "openstack")
         puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
         exit
         @client = ''
      elsif (config[:cloud].nil?)
         Chef::Log.error "You have misspell the word or you might have not chose the cloud provider "
        exit
      else
        exit
      end

      # validating data_bag
      data_bag_find = check_data_bag
        if data_bag_find == 0
          create_network(name)
        else
          puts "#{ui.color('Network already exists please check', :cyan)}"
        end
    end

    def check_data_bag
      if Chef::DataBag.list.key?("networks")
        puts ''
        puts "#{ui.color('Found databag for this', :cyan)}"
        puts "#{ui.color('Searching data for current application in to the data bag', :cyan)}"
        puts ''
        query = Chef::Search::Query.new
        query_value = query.search(:networks, "id:#{config[:name]}")
        if query_value[2] == 1
          puts ""
          puts "#{ui.color("The loadbalancer by name #{config[:name]} already exists please check", :cyan)}"
          puts "#{ui.color("Hence we are quiting ", :cyan)}"
          puts ""
          exit
        else
          puts "#{ui.color("The data bag item #{config[:name]} is not present")}"
          puts "#{ui.color("Hence we are Creating #{config[:name]}_network ", :cyan)}"
          return 0
        end
      else
        puts ''
        puts "#{ui.color("Didn't found databag for this", :cyan)}"
        puts "#{ui.color("Hence we are Creating #{config[:name]}_network ", :cyan)}"
        return 0
      end
    end

    def create_network(name)


      if config[:cloud] == "azure"

#-----------------creation of Security Group----------------
        puts "#{ui.color('Creating Security group for the environment', :cyan)}"
        azure_nsg1 = @client.create_security_group("#{name}_nsg1", config[:resource_group])
        azure_nsg2 = @client.create_security_group("#{name}_nsg2", config[:resource_group])

#-------------------creation of Security Rule for Nsg----------------
        puts "#{ui.color('Creating Security rule for the subnets', :cyan)}"
        security_rule1 = @client.create_security_rule_for_nsg("#{name}_nsg_rule", "#{name}_nsg1", sub_cidr1, config[:resource_group])
        security_rule2 = @client.create_security_rule_for_nsg("#{name}_nsg_rule", "#{name}_nsg2", sub_cidr2, config[:resource_group])
        puts "#{ui.color('security rules is written successfully', :cyan)}"
        puts ""

#-----------------------creation of VPN----------------------
        puts "#{ui.color('Creating vpc for the environment', :cyan)}"
        azure_vpn = @client.create_vpc(config[:resource_group], "#{name}_vpn", config[:vpc_cidr_block])

#------------------creation of Route Table----------------------
        puts "#{ui.color('Creating Route Tables for the environment', :cyan)}"
        puts " "
        azure_route_table1 = @client.create_route_table("#{name}_route_table1", sub_cidr1, config[:resource_group])
        puts "#{ui.color('Created Route Table 1 for the environment', :cyan)}"
        puts " "
        azure_route_table2 = @client.create_route_table("#{name}_route_table2", sub_cidr2, config[:resource_group])
        puts "#{ui.color('Created Route Table 2 for the environment', :cyan)}"
        puts " "

#-------------------------creation of Subnet--------------------------
        puts "#{ui.color('creating subnet for the environment', :cyan)}"
        azure_sub1 = @client.create_subnet(sub1_name,sub_cidr1, "#{name}_vpn", "#{name}_nsg1", "#{name}_route_table1", config[:resource_group])
        azure_sub2 = @client.create_subnet(sub2_name,sub_cidr2, "#{name}_vpn", "#{name}_nsg2", "#{name}_route_table2", config[:resource_group])
        ec2_vpc,ec2_subnet1,ec2_subnet2,ec2_security = ""

      elsif config[:cloud] == "aws"

#------------ creation of VPC--------------------------------
        puts "#{ui.color('creating vpc for the environment', :cyan)}"
        ec2_vpc = @client.create_vpc(name,config[:vpc_cidr_block].to_s.tr("[]", '').tr('"', ''))
        puts "#{config[:subnet_cidr_block].size.times}"

#------------  creation of Subnet----------------------------
        puts "#{ui.color('creating subnet for the environment', :cyan)}"
        ec2_subnet = []
        n = config[:subnet_cidr_block].size-1
        config[:subnet_cidr_block].size.times do |s|
          ec2_subnet[s] = @client.create_subnet(config[:subnet_cidr_block][n].to_s.tr("[]", '').tr('"', ''),ec2_vpc,"sub#{n}_name","us-west-2a")
          n -=1;
        end

#------------ creation of IGW--------------------------------
        puts "#{ui.color('creating Internet Gateway for the environment', :cyan)}"
        ec2_igw = @client.create_igw(name,ec2_vpc)

#------------ creation of Route Table-------------------------
        ec2_sub = ec2_subnet.reverse
        puts "#{ui.color('creating Route Table for the environment', :cyan)}"
        ec2_route = []
        m = config[:subnet_cidr_block].size-1
        config[:subnet_cidr_block].size.times do
          ec2_route[m] = @client.create_route_table(ec2_vpc,"name_#{m}",ec2_igw,ec2_sub[m])
          m -=1;
        end

#------------ creation of Security Group----------------------
        puts "#{ui.color('creating Security group for the environment', :cyan)}"
        ec2_security = @client.create_security_group(name,ec2_vpc)

      elsif config[:cloud] == "google"
        puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
        exit
      elsif config[:cloud] == "openstack"
        puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
        exit
      end
      store_network_data(name,ec2_vpc,ec2_subnet,ec2_security)
    end

    def store_network_data(name,ec2_vpc,ec2_subnet,ec2_security)
     if Chef::DataBag.list.key?("networks")
       puts ''
       puts "#{ui.color('Found databag for this', :cyan)}"
       puts "#{ui.color('Writing data in to the data bag item', :cyan)}"
       puts ''

       if config[:cloud] == "azure"
       data = {
              'id' => "azure_#{name}",
              'VPC-ID' => "#{name}_vpn",
              'SUBNET-ID' => ["#{name}_sub1","#{name}_sub2"],
              'SECURITY-ID' => ["#{name}_nsg1","#{name}_nsg2"],
              'ROUTE-ID' => ["#{name}_route_table1","#{name}_route_table2"]
              }
       elsif config[:cloud] == "aws"
       data = {
              'id' => "aws_#{name}",
              'VPC-ID' => "#{ec2_vpc}",
              'SUBNET-ID' => ec2_subnet.reverse,
              'SECURITY-ID' => "#{ec2_security}"
              }
       elsif config[:cloud] == "google"
         puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
       elsif config[:cloud] == "openstack"
         puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
       end
       dengine_item = Chef::DataBagItem.new
       dengine_item.data_bag("networks")
       dengine_item.raw_data = data
       dengine_item.save

       puts "#{ui.color('Data has been written in to databag successfully', :cyan)}"
     else
       puts ''
       puts "#{ui.color('Was not able to fine databag for this', :cyan)}"
       puts "#{ui.color('Hence creating databag', :cyan)}"
       puts ''
       users = Chef::DataBag.new
       users.name("networks")
       users.create
       if config[:cloud] == "azure"
       data = {
              'id' => "azure_#{name}",
              'VPC-ID' => "#{name}_vpn",
              'SUBNET-ID' => ["#{name}_sub1","#{name}_sub2"],
              'SECURITY-ID' => ["#{name}_nsg1","#{name}_nsg2"],
              'ROUTE-ID' => ["#{name}_route_table1","#{name}_route_table2"]
              }
       elsif config[:cloud] == "aws"
       data = {
              'id' => "aws_#{name}",
              'VPC-ID' => "#{ec2_vpc}",
              'SUBNET-ID' => ec2_subnet.reverse,
              'SECURITY-ID' => "#{ec2_security}"
              }
       elsif config[:cloud] == "google"
         puts "#{ui.color('we are in alfa, we soon we will be here', :cyan)}"
       elsif config[:cloud] == "openstack"
         puts "#{ui.color('we are in alfa, we soon we will be here', :cyan)}"
       end
       dengine_item = Chef::DataBagItem.new
       dengine_item.data_bag("networks")
       dengine_item.raw_data = data
       dengine_item.save
       puts "#{ui.color('Data has been written in to databag successfully', :cyan)}"
       end
    end

  end
end
