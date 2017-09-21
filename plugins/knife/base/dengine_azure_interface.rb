require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_client_base"

module Engine
  class DengineAzureInterface < Chef::Knife

    include DengineClientBase

#---------------------Creation of VPN----------------------------
	
    def create_vpc(resource_group, name, vpn_cidr)

      params = VirtualNetwork.new

      address_space = AddressSpace.new
      address_space.address_prefixes = ["#{vpn_cidr}"]
      params.address_space = address_space

      params.location = 'CentralIndia'

      puts "#{ui.color('VPN creation has been started', :cyan)}"
      puts ''
      puts "#{ui.color('VPN creation in progress', :cyan)}"
      puts ''
      promise = azure_network_client.virtual_networks.create_or_update("#{resource_group}", "#{name}", params)
      puts "#{ui.color('VPN creation is completed', :cyan)}"
      puts ''
      puts "========================================================="
      puts "#{ui.color('VPN name is:', :magenta)}   :#{promise.name}"
	  puts "#{ui.color('VPN id is:', :magenta)}     :#{promise.id}"
#      puts "name = #{promise.name}"
#      puts "id = #{promise.id}"
      puts "========================================================="
    end

#----------------------Creation of Subnets------------------------

    def create_subnet(name,cidr, vpn_name, nsg_name, route_table, resource_group)
    subnet = azure_network_service.subnets.create(
      name: "#{name}",
      resource_group: "#{resource_group}",
      virtual_network_name: "#{vpn_name}",
      address_prefix: "#{cidr}",
      network_security_group_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/networkSecurityGroups/#{nsg_name}",
      route_table_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/routeTables/#{route_table}"
      )
    end

#-----------------------Creation of NSG--------------------------------
  
    def create_security_group(name, resource_group)

      params = NetworkSecurityGroup.new
      params.location = "CentralIndia"

      puts "#{ui.color('NSG creation has been started', :cyan)}"
      puts ''
      puts "#{ui.color('NSG creation in progress', :cyan)}"
      puts ''
      promise = azure_network_client.network_security_groups.create_or_update("#{resource_group}", "#{name}", params)
      puts "#{ui.color('NSG creation is completed', :cyan)}"
	  puts " "
      puts "========================================================="
      puts "#{ui.color('NSG name is:', :magenta)}   :#{promise.name}"
#	  puts "name = #{promise.name}"
      puts "#{ui.color('NSG id is:', :magenta)}     :#{promise.id}"
#      puts "id = #{promise.id}"
      puts "========================================================="
    end

#----------Creation of Security Rule and adding to NSG	---------------
	
   def create_security_rule_for_nsg(name, nsg_name, sub_cidr, resource_group)

      params = SecurityRule.new
      params.description = "AllowSSHProtocol"
      params.protocol = 'Tcp'
      params.source_port_range = '*'
      params.destination_port_range = '22'
      params.source_address_prefix = '*'
      params.destination_address_prefix = "#{sub_cidr}"
      params.access = 'Allow'
      params.priority = '100'
      params.direction = 'Inbound'
      promise = azure_network_client.security_rules.create_or_update("#{resource_group}", "#{nsg_name}", "#{name}", params)
		
    end
	
#-----------------------Creation of ROUTE Table----------------------------

    def create_route_table(name, sub_cidr, resource_group)
      params = RouteTable.new

      rou = Route.new
      rou.name = "#{name}_route"
      rou.address_prefix = "#{sub_cidr}"
      rou.next_hop_type = 'VirtualNetworkGateway'

      params.routes = [rou]
      params.location = 'CentralIndia'
      puts "#{ui.color('Route table creation has been started', :cyan)}"
      puts ''
      puts "#{ui.color('Route table creation in progress', :cyan)}"
      puts ''
      route_table = azure_network_client.route_tables.create_or_update("#{resource_group}", "#{name}", params)
      puts "#{ui.color('Route table creation is completed', :cyan)}"
      puts " "
    end

#--------------------Creating AvailabilitySet for Backend pool---------------

    def create_availability_set(resource_group,name)
      puts ""
      puts "#{ui.color('Creating AvailabilitySet for Backend pool of Loadbalancer', :cyan)}"
      puts ""
      params = AvailabilitySet.new
      params.platform_update_domain_count = 5
      params.platform_fault_domain_count = 2
      params.managed = true
      params.location = "CentralIndia"
      puts ''
      puts "#{ui.color('avalablility set creation in progress', :cyan)}"
      promise = azure_compute_client.availability_sets.create_or_update("#{resource_group}", "#{name}_availability_set", params)
      puts ''
      puts "#{ui.color('avalablility set creation is completed', :cyan)}"
      puts "========================================================="
      puts "#{ui.color('avalablility set name:', :magenta)} :#{promise.name}"
      puts "#{ui.color('avalablility set id:', :magenta)}   :#{promise.id}"
      puts "========================================================="

      return promise.name
    end

#----------------Creating Public IP for Loadbalancer-------------------

    def create_public_ip(resource_group,name)
      puts ""
      puts "#{ui.color('Creating Public IP for Loadbalancer', :cyan)}"
      puts ""
      puts "#{ui.color('', :cyan)}"
      pubip = azure_network_service.public_ips.create(
         name: "#{name}-lbip",
         resource_group: "#{resource_group}",
         location: 'CentralIndia',
         public_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic,
         idle_timeout_in_minutes: 4,
         domain_name_label: "#{name}-lbip".downcase
      )
      puts ''
      puts "#{ui.color('Public IP creation is completed', :cyan)}"
      puts "========================================================="
      puts "#{ui.color('Public IP name:', :magenta)} :#{pubip.name}"
      puts "#{ui.color('Public IP id:', :magenta)}   :#{pubip.id}"
      puts "#{ui.color('Public IP FQDN:', :magenta)} :#{pubip.fqdn}"
      puts "========================================================="

      return pubip.fqdn
    end

#-------------------------Creating Loadbalancer-----------------------------

    def create_lb(resource_group,name)
      envmnt = "#{name}".downcase
      lb_dns_name = create_public_ip(resource_group,envmnt)
      puts ""
      puts "Creating Loadbalancer"
      lb = azure_network_service.load_balancers.create(
      name: "#{name}",
      resource_group: "#{resource_group}",
      location: 'CentralIndia',
            frontend_ip_configurations:
                [
                  {
                    name: "#{name}-lbip",
                    private_ipallocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic,
                    public_ipaddress_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/publicIPAddresses/#{name}-lbip"
                  }
                ],
            backend_address_pool_names:
                [
                    "#{name}_vm_pool"
                ],
            probes:
                [
                  {
                    name: 'HealthProbe',
                    protocol: 'http',
                    request_path: 'index.html',
                    port: '80',
                    interval_in_seconds: 5,
                    load_balancing_rules: 'lb_rule',
                    number_of_probes: 2,
                    load_balancing_rule_id: "/subscriptions/0594cd49-9185-425d-9fe2-8d051e4c6054/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{name}/loadBalancingRules/lb_rule"
                  }
                ],
            load_balancing_rules:
                [
                  {
                    name: 'lb_rule',
                    frontend_ip_configuration_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{name}/frontendIPConfigurations/#{name}-lbip",
                    backend_address_pool_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{name}/backendAddressPools/#{name}_vm_pool",
                    protocol: 'Tcp',
                    frontend_port: '80',
                    backend_port: '80',
                    enable_floating_ip: false,
                    idle_timeout_in_minutes: 4,
                    load_distribution: "Default",
                    probe_id: "/subscriptions/0594cd49-9185-425d-9fe2-8d051e4c6054/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{name}/probes/HealthProbe"
                  }
                ],
            inbound_nat_rules:
                [
                  {
                    name: 'nat1',
                    frontend_ip_configuration_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{name}/frontendIPConfigurations/#{name}-lbip",
                    protocol: 'Tcp',
                    frontend_port: 1121,
                    port_mapping: false,
                    backend_port: 1211
                  },
                  {
                    name: 'nat2',
                    frontend_ip_configuration_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{name}/frontendIPConfigurations/#{name}-lbip",
                    protocol: 'Tcp',
                    frontend_port: 1122,
                    port_mapping: false,
                    backend_port: 1212
                  },
                  {
                    name: 'nat3',
                    frontend_ip_configuration_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{resource_group}/providers/Microsoft.Network/loadBalancers/#{name}/frontendIPConfigurations/#{name}-lbip",
                    protocol: 'Tcp',
                    frontend_port: 1123,
                    port_mapping: false,
                    backend_port: 1213
                  }
                ]
      )

      puts ''
      puts "#{ui.color('Loadbalancer creation is completed', :cyan)}"
      puts "========================================================="
      puts "#{ui.color('Loadbalancer name:', :magenta)}     :#{lb.name}"
      puts "#{ui.color('Loadbalancer id:', :magenta)}       :#{lb.id}"
      puts "#{ui.color('Loadbalancer dns name:', :magenta)} :#{lb_dns_name}"
      puts "========================================================="

      return lb_dns_name
    end

  end
end