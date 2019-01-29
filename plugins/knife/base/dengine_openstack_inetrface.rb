require "#{File.dirname(__FILE__)}/dengine_client_base"
require "#{File.dirname(__FILE__)}/dengine_data_tresure"

module Engine
  class DengineOpenstackInterface < Chef::Knife

    include DengineClientBase
    include DengineDataTresure

    deps do
      require 'readline'
      require 'chef/json_compat'
      require 'chef/knife/openstack_server_create'
      Chef::Knife::OpenstackServerCreate.load_deps
    end

#-----------------------------------creating VPC--------------------------------------
    def create_vpc(name)
      puts "#{ui.color('VPC creation has been started', :cyan)}"
      puts ''
      puts "#{ui.color('VPC creation in progress', :cyan)}"
      vpc = openstack_network_connection.create_network(networkname)
      puts ''
      puts "#{ui.color('VPC is created', :cyan)}"
      vpc_id = "#{vpc.id}"

      puts ''
      puts "========================================================="
      puts "#{ui.color('vpc-name', :magenta)}         : #{name}"
      puts "#{ui.color('vpc-id', :magenta)}           : #{vpc_id}"
      puts "========================================================="
      puts ''

      return vpc_id
    end

#------------------------------creating subnet----------------------------------

    def get_availability_zones

    end

    def create_subnet(name,vpc_id,cidr,ip_version,gateway_ip)
      puts "#{ui.color('subnet creation has been started', :cyan)}"
      subnet = openstack_network_connection.create_subnet(vpc_id,cidr,ip_version,opts = {"name" => "sub_#{name}", "gateway_ip" => gateway_ip})
      subnet_id = subnet.id
      puts "."
      puts "."
      puts "#{ui.color('SUBNET creation in progress', :cyan)}"
      puts ''

      puts "#{ui.color('SUBNET is created', :cyan)}"

      puts ''
      puts "========================================================="
      puts "#{ui.color('subnet-name', :magenta)}      : #{name}"
      puts "#{ui.color('subnet-ids', :magenta)}       : #{subnet_id}"
      puts "========================================================="

      return subnet_id
    end

#----------------------------------creating IGW--------------------------------
    def create_igw(subnet_name,vpc_id)

    end

#----------------------creating route table------------------------

    def create_route_table(vpc_id,subnet_name,internet_gateway,subnet)

    end

#----------------------creating security group------------------------
    def create_security_group(name,vpc_id)

    end

#---------------------Creation of Load Balancer-------------------------------

     def create_application_loadbalancer(name,subnet_id1,subnet_id2,security_group)

     end

     def create_classic_loadbalancer(name,subnet_id1,subnet_id2,security_group,protocol,loadbalancerport,vpc,instanceprotocol,instanceport)

     end

#----------------adding instances to load balancers--------------

    def register_server_to_load_balancers(elb_name,instanceid,type)

    end

#--------------------------creation of server-----------------------------

    def create_server(node_name,runlist,env,security_group,image,ssh_user,ssh_key_name,identify_file,region,flavor,chef_env,network_id)

      create = Chef::Knife::OpenstackServerCreate.new

      create.config[:openstack_auth_url]  = Chef::Config[:knife][:openstack_auth_url]
      create.config[:openstack_username]  = Chef::Config[:knife][:openstack_username]
      create.config[:openstack_password]  = Chef::Config[:knife][:openstack_password]
      create.config[:flavor]              = flavor
      create.config[:image]               = image
      create.config[:security_group_ids]  = security_group
      create.config[:chef_node_name]      = node_name
      create.config[:ssh_user]            = ssh_user
      create.config[:ssh_port]            = 22
      create.config[:ssh_key_name]        = ssh_key_name
      create.config[:identity_file]       = identify_file
      create.config[:run_list]            = runlist
      create.config[:network_id]          = env
      #create.config[:associate_public_ip] = true
      create.config[:region]              = region
      create.config[:environment]         = chef_env

      value = create.run

      puts "-------------------------"
      puts "NODE-NAME: #{node_name}"
      puts "ENV      : #{chef_env}"
      puts "-------------------------"

    end

#-------------------------------server backup---------------------------

    def create_image(instance_id,image_name,descrip)


    end

  end
end
