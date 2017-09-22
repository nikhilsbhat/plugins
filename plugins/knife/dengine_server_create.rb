require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_interface"
require "#{File.dirname(__FILE__)}/base/dengine_aws_interface"
require "#{File.dirname(__FILE__)}/base/dengine_google_interface"
require "#{File.dirname(__FILE__)}/base/dengine_data_tresure"

module Engine
  class DengineServerCreate < Chef::Knife

    include DengineDataTresure

    banner 'knife dengine server create (options)'

      option :app,
        :short => '-a APP_NAME',
        :long => '--app_name APP_NAME',
        :description => "Name of the application for which the stack is being created."

      option :id,
        :short => '-i UNIQUE_ID',
        :long => '--id UNIQUE_ID',
        :description => "Give your server a unique ID inorder to make it different from others.",
        :default => 0

      option :network,
        :short => '-n ENV_NETWORK',
        :long => '--network ENV_NETWORK',
        :description => "In which network the server has to be created",
        :default => "default"

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

      option :cloud,
        :long => '--cloud CLOUD_PROVIDER_NAME',
        :description => "The name of the cloud provider for ex: aws, azure, google, openstack etc"

      option :machine_user,
        :short => '-m MACHINE_USER',
        :long => '--machine-user MACHINE_USER',
        :description => "Name of the user that has to be assigned fo VM.",
        :default => "ubuntu"

      option :boot_disk_size,
        :long => "--boot-disk-size SIZE",
        :description => "Size of the persistent boot disk between 10 and 10000 GB, specified in GB; default is '10' GB, this is exclusively for GCP",
        :default => "10"

    def run

      if config[:cloud] == "aws"
        @client = DengineAwsInterface.new
      elsif config[:cloud] == "azure"
        @client = DengineAzureInterface.new
      elsif config[:cloud] == "google"
        @client = DengineGoogleInterface.new
      elsif config[:cloud] == "openstack"
        puts "#{ui.color('we are in alfa, soon we will be here', :cyan)}"
        exit
        @client = ''
	  elsif (config[:cloud].nil?)
        Chef::Log.error "You have misspell the word or you might have not chose the cloud provider "
        exit
      end

      server_create
 
    end

    def server_create

      flavor         = config[:flavor]
      chef_env       = config[:environment]
      chef_role      = check_role("#{config[:role]}")
      node_name      = set_node_name("#{config[:app]}","#{config[:role]}","#{config[:environment]}","#{config[:id]}")
      runlist        = set_runlist("#{config[:role]}")
      ssh_user       = "#{config[:machine_user]}"
      ssh_key_name   = Chef::Config[:knife][:ssh_key_name]
      identify_file  = Chef::Config[:knife][:identity_file]

      if config[:cloud] == "aws"

        sg_group       = get_security_group("#{config[:network]}")
        got_env        = get_subnet_id("#{config[:network]}")
        env            = got_env.first
        security_group = ["#{sg_group}"]
        image          = Chef::Config[:knife][:image]
        region         = Chef::Config[:knife][:region]

        @client.server_create(node_name,runlist,env,security_group,image,ssh_user,ssh_key_name,identify_file,region,flavor,chef_env)
        return node_name

      elsif config[:cloud] == "azure"
      elsif config[:cloud] == "google"

#        sg_group       = get_security_group("#{config[:cloud}-#{config[:network]}")
#        got_env        = get_env("#{config[:cloud}-#{config[:network]}")
        env            = ""
        boot_disk      = config[:boot_disk_size]
        network        = "#{config[:network]}"
        image          = Chef::Config[:knife][:gce_image]
        gateway_key    = Chef::Config[:knife][:gateway_key]
        zone           = Chef::Config[:knife][:gce_zone]

        @client.server_create(node_name,runlist,env,network,image,ssh_user,ssh_key_name,identify_file,flavor,chef_env,gateway_key,zone,boot_disk)
        return node_name

      elsif config[:cloud] == "openstack"
	  elsif (config[:cloud].nil?)
        Chef::Log.error "You have misspell the word or you might have not chose the cloud provider "
        exit
      end

    end

  end
end
