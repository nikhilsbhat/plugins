require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_server_create"
require "#{File.dirname(__FILE__)}/dengine_elb_create"
require "#{File.dirname(__FILE__)}/dengine_elb_add_instance"

module Engine
  class DengineMasterCreate < Chef::Knife

    def self.included(includer)
      includer.class_eval do
        deps do
          require 'chef/search/query'
        end
      end
    end

    deps do

      Engine::DengineServerCreate.load_deps
      Engine::DengineElbCreate.load_deps
      Engine::DengineElbAddInstance.load_deps

    end

    banner 'knife dengine master create (options)'

      option :build,
        :short => '-b BUILD_TOOL',
        :long => '--build BUILD_TOOL',
        :description => "In which Environment the server has to be created.",
        :default => "maven"

      option :artifact,
        :short => '-a ARTIFACT_TOOL',
        :long => '--artifact ARTIFACT_TOOL',
        :description => "Which chef role to use. Run 'knifeknife role list' for a list of roles.",
        :default => "jfrog"

      option :ci,
        :short => '-i CI_SERVER',
        :long => '--ci CI_SERVER',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "jenkins"

      option :database,
        :short => '-d DATABASE',
        :long => '--database DATABASE',
        :description => "In which Environment the server has to be created.",
        :default => "mysql"

      option :webserver,
        :short => '-w WEBSERVER',
        :long => '--webserver WEBSERVER',
        :description => "Which chef role to use. Run 'knifeknife role list' for a list of roles.",
        :default => "tomcat"

      option :uat_db_tr,
        :long => '--uat_db_tr UAT_DB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

      option :uat_wb_tr,
        :long => '--uat_wb_tr UAT_WB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

      option :uat_wb_no,
        :long => '--uat_wb_no UAT_WB_SERVER_NUMBER',
        :description => "The number of servers that has to be created under the role web for UAT environment.",
        :default => 1

      option :prod_db_tr,
        :long => '--prod_db_tr PROD_DB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

      option :prod_wb_tr,
        :long => '--prod_wb_tr PROD_WB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

      option :prod_wb_no,
        :long => '--prod_wb_no PROD_WB_SERVER_NUMBER',
        :description => "The number of servers that has to be created under the role web for PROD environment.",
        :default => 1

    def run

      mngt_env = "MNGT"
      uat_env  = "UAT"
      prod_env = "PROD"
      mngt_flavor = "t2.micro"
      build = config[:build]
      artifact = config[:artifact]
      ci = config[:ci]
      architecture = config[:architecture]
      database = config[:database]
      webserver = config[:webserver]
      uat_db_tr = config[:uat_db_tr]
      uat_wb_tr = config[:uat_wb_tr]
      value_uat = config[:uat_wb_no].to_i
      prod_db_tr = config[:prod_db_tr]
      prod_wb_tr = config[:prod_wb_tr]
      value_prod = config[:prod_wb_no].to_i

#---------------------------management-servers-------------------------------
 # provisioning build
     # create_machine(mngt_env,"management",build,mngt_flavor)

 # provisioning artifact
     # create_machine(mngt_env,"management",artifact,mngt_flavor)

 # provisioning ci
     # create_machine(mngt_env,"management",ci,mngt_flavor)


#-----------------------creation-of-load_balancers-uat-----------------------
      if value_uat > 1
       puts "creating ELB"
       create_elb("#{uat_env}ELB",uat_env)
      else
        puts "#{ui.color('Not creating load balancer as it was not opted', :cyan)}"
      end
#------------------------------uat-servers-----------------------------------
 # provisioning dev
      #create_machine(uat_env,"development",database,uat_db_tr)

#------------mechanism to create instance and add it into load balancer UAT--------
      if value_uat > 1
        $i = 0 
        while $i < value_uat  do
          node_uat = create_machine(uat_env,"development-#$i",webserver,uat_wb_tr)

         # fetching instance_id of machine

          instance_id_uat = fetch_instance_id(node_uat)
      #--------------------adding instance to load_balancers-uat--------------------
      # addind instance to load_balancers

          add_instance("#{uat_env}ELB",instance_id_uat)
          $i +=1
        end
      else
        create_machine(uat_env,"development",webserver,uat_wb_tr)
      end

#-----------------------------------------------------------------------------

#-----------------------creation-of-load_balancers-prod----------------------
 # creating load_balancers
      if value_prod > 1
        puts "creating ELB"
        create_elb("#{prod_env}ELB",prod_env)
      else
        puts "#{ui.color('Not creating load balancer as it was not opted', :cyan)}"
      end
#----------------------------prod-servers------------------------------------
 # provisioning prod
      #create_machine(prod_env,"production",database,prod_db_tr)

#------------mechanism to create instance for web and add it into load balancer PROD--------
      if value_prod > 1
        $j = 0
        while $j < value_prod  do
        node_prod = create_machine(prod_env,"production-#$j",webserver,prod_wb_tr)

        # fetching instance_id of machine

        instance_id_prod = fetch_instance_id(node_prod)
        #--------------------adding instance to load_balancers-prod--------------------
        # addind instance to load_balancers

        add_instance("#{prod_env}ELB",instance_id_prod)
        $j +=1
        end
     else 
       create_machine(prod_env,"production",webserver,prod_wb_tr)
     end
#--------------------------------------------------------------------------------------------
    end

    def create_machine(network,env,role,flavor)

      puts "I recived a value #{env} as a env"
      server_create = Engine::DengineServerCreate.new
      test = server_create.config[:environment]  = env
      test1 = server_create.config[:role]        = role
      test2 = server_create.config[:flavor]      = flavor
      test3 = server_create.config[:network]     = network

      id = server_create.run
      return id

    end

    def create_elb(elb_name,env)
      
      elb_create = Engine::DengineElbCreate.new
      elb_create.config[:name]              = elb_name
      elb_create.config[:env]               = env
      elb_create.config[:listener_lb_port]  = 80
      elb_create.config[:listener_protocol] = "HTTP"

      elb_create.run

    end

    def add_instance(elb_name,instance_id)

      instance_add = Engine::DengineElbAddInstance.new
      instance_add.config[:elb_name]    = elb_name
      instance_add.config[:instance_id] = instance_id

      instance_add.run

    end

    def fetch_instance_id(node)

      search = Chef::Knife::Search.new
      search.name_args = ['node', "name:#{node}"]
      out = search.run
      value = Array.new
      out.each do |node|
      value = node["ec2"]["instance_id"]
      end
      puts value
      return value

    end

  end
end
