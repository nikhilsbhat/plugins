require 'chef/knife'
#require "#{File.dirname(__FILE__)}/dengine_server_base"
require "#{File.dirname(__FILE__)}/dengine_server_create"

module Engine
  class DengineMasterCreate < Chef::Knife

    deps do
      Chef::Knife::DengineServerCreate.load_deps
      #Chef::Knife::DengineServerCreate.load_deps
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

      option :dev_db_tr,
        :long => '--dev_db_tr DEV_DB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

      option :dev_wb_tr,
        :long => '--dev_wb_tr DEV_WB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

      option :tst_db_tr,
        :long => '--tst_db_tr TEST_DB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

      option :tst_wb_tr,
        :long => '--tst_wb_tr TST_WB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

      option :acc_db_tr,
        :long => '--acc_db_tr ACC_DB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

      option :acc_wb_tr,
        :long => '--acc_wb_tr ACC_WB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

      option :prod_db_tr,
        :long => '--prod_db_tr PROD_DB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

      option :prod_wb_tr,
        :long => '--prod_wb_tr PROD_WB_FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine.",
        :default => "t2.micro"

    def run

      mngt_env = "MNGT"
      mngt_flavor = "t2.micro"
      build = config[:build]
      artifact = config[:artifact]
      ci = config[:ci]
      architecture = config[:architecture]
      database = config[:database]
      webserver = config[:webserver]
      dev_db_tr = config[:dev_db_tr]
      dev_wb_tr = config[:dev_wb_tr]
      tst_db_tr = config[:tst_db_tr]
      tst_wb_tr = config[:tst_wb_tr]
      acc_db_tr = config[:acc_db_tr]
      acc_wb_tr = config[:acc_wb_tr]
      prod_db_tr = config[:prod_db_tr]
      prod_wb_tr = config[:prod_wb_tr]

#---------------------------management-servers--------------------------------------
 # provisioning build
    create_machine(mngt_env,"management",build,mngt_flavor)

 # provisioning artifact
    create_machine(mngt_env,"management",artifact,mngt_flavor)

 # provisioning ci
    create_machine(mngt_env,"management",ci,mngt_flavor)

#------------------------------uat-servers--------------------------------------
 # provisioning dev
    create_machine("UAT","development",database,dev_db_tr)
    create_machine("UAT","development",webserver,dev_wb_tr)

 # provisioning test
    create_machine("UAT","test",database,tst_db_tr)
    create_machine("UAT","test",webserver,tst_wb_tr)

 # provisioning acceptance
    create_machine("UAT","acceptance",database,acc_db_tr)
    create_machine("UAT","acceptance",webserver,acc_wb_tr)

#----------------------------prod-servers---------------------------------------
 # provisioning prod
    create_machine("PROD","production",database,prod_db_tr)
    create_machine("PROD","production",webserver,prod_wb_tr)

#--------------------------------------------------------------------------------
    end

    def create_machine(network,env,role,flavor)

        server_create = Chef::Knife::DengineServerCreate.new
        test = server_create.config[:environment]  = env
        test1 = server_create.config[:role]        = role
        test2 = server_create.config[:flavor]      = flavor
        test3 = server_create.config[:network]     = network

        server_create.run
    end

  end
end
