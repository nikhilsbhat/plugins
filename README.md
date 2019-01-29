# knife-dengine

A custom knife plugin which lets you create resources in a cloud agostic manner.
It has few more aspects other than creating cloud resources:
	* plugin to test the IAC written as part of framework `knife dengine validate iac`.
	* deploy the application into the environment you need `knife dengine app deploy`.
	* promotion of IAC from one environment to another `knife dengine env promote`.
	...and many more

read this document to understand this plugun better.

It helps in creating loadbalancer in AWS, storing its value in chef.
It helps in creating custom images using Packer, for this I have used [packer-config](https://github.com/ianchesal/packer-config)
this packer blend plugin help in creating custom image.


## Download

    Since a custom gem is not built for this yet, if one has to use this plugins
	then folder containing plugins has to be placed under '.chef/plugins/' as 'knife'

## Requires

    This requires aws-sdk-ruby to work, make sure this is installed in the workstation.
	In the latest version of chef this is aws-sdk-ruby is embedded with chef-gem.

## knife dengine Subcommands

This plugin provides the following Knife subcommands. Specific command options can be found by invoking the subcommand with a `--help` flag

### `knife dengine network create`

```bash
    knife dengine network create (options)
```

This helps one in creating network in the cloud they need (this works with aws/azure now)
All one has to do is to pass the basic components required to create a network such as CIDRs of network.
This can create the subnets dynamically, which means one no need to create subnet one by one.
One has to pass the CIDRs of subnets as a string separated by commas like this `"192.168.10.0/24,192.168.20.0/24"`.
The plugin will understand that user needs two subnets to be created for the network and it will created two subnets and attach to the VPC which it creates.

Sample usage is as below:

```bash
    knife dengine network create --cloud 'aws' --name 'test-network' --vpc-cidr-block '192.168.0.0/16' --subnet-cidr-block '192.168.10.0/24,192.168.20.0/24'
	# --cloud will specify in which clooud the network has to be created.
	# --name will assign the network a name.
	# --vpc-cidr-block CIDR block/iprange your network should have.
	# --subnet-cidr-block CIDRs of the subnet that has to be created in the network, the comma separated value will specify how many subnet has to be created.
```

### `knife dengine server create`

```bash
    knife dengine server create (options)
```

This lets you create a server in aws/azure/gcp, you can select the cloud while invoking this plugin.
All one has to use flag `--cloud` and pass the cloud they need.

The above command will introduce you ino to this in deep by letting you know all the flags it has.
The below an example of how to use it. It is better to know few aspects about this before using it.
If certain flags are not passed it will try to read the data from databag automatically which it should suppose to.
If it finds the valid data well and good else this is going to throw an error.

#### Note

Every command here will try to store the data into databag once resource is successfully created.
This will be done to make sure that all created resources will be in tight coupled with chef.

```bash
    knife dengine server create --id '1' --network 'network-id' --environment 'development' --role 'role[tomcat]' --flavor 't2.micro' --cloud 'aws' --machine-user 'dengine' --resource-group-name 'dengine' --lb-name 'dengine-development'
	# --id, will make your chef node unique, it defaults to some random number if not used. (it can be jenkins job id if this is invoked froom jenkins).
	# --network, id of network in which the server has to be created, subnet-if if cloud is aws.
	# --environment, the name of environment of chef in which the server has to be created. It defaults to `_default`
	# --role, the runlist that has to be assigned to the server which will be created.
	# --flavor, the hardware specs of the servers which has to be created.
	# --cloud, this will specify in which cloud the server has to be created.
	# --machine-user, the username by which chef has to authenticate the server. It defaults to `ubuntu`
	# --resource-group-name, this flag has to be invoked only if the cloud is `azure`.
	# --lb-name, this is the most interesting part. If the server has to be part of any loadbalancer then specify the name/id of loadbalancer here.
```

### `knife dengine server backup`

```bash
    knife dengine server backup (options)
```

This lets you take backup of the servers which is part of the setup.


### `knife dengine load balancer create`

This helps one in creating network/application loadbalancers in both aws/azure, and it will store its **details in databag** for future use

```bash
   knife dengine load balancer create (options)
```

### `knife dengine origin create`

This will be helpful if one needs `storage-account` or `resource-group` in azure.

```bash
   knife dengine origin create (options)
```

### `knife dengine env promote`

These IAC are programs and even these needs the deployment and this plugin does exactly the same.
Promoting IAC(cookbooks) from one environment to another.

```bash
   knife dengine env promote source_env dest_env
```

### `knife dengine validate iac`

As mentioned earlier, even IACs are programs and testing them is mandate before pushing them environment.
And this command does the same, it test the IAC for syntaxes and standards and then let person use it.

```bash
   knife dengie validate iac (options)
```

## samle knife.rb

As this plugin does some major works, it is better to store minimun details in knife to avoid calling it repeatedly.
A sample knife file is mentioned below.

```ruby
current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                'chefcoe'
client_key               "#{current_dir}/.chef/chefcoe.pem"
validation_client_name   'chef-validator'
validation_key           "#{current_dir}/.chef/masterchefcoe-validator.pem"
chef_server_url          'https://ec2-XX-XXX-XXX-XXX.us-west-2.compute.amazonaws.com/organizations/chef'
cookbook_path            ["#{current_dir}/cookbooks"]
syntax_check_cache_path  "#{current_dir}../syntax_cache"
ssl_verify_mode    :verify_none

knife[:editor]   = "vi"
#knife[:supermarket_site] = "https://ec2-XX-XX-XX-XX.us-west-2.compute.amazonaws.com"
knife[:ssh_user] = 'ubuntu'
# The data required by knife to authenticate with AWS console/account
#knife[:aws_credential_file] = '/root/chef-repo/.chef/credentials/aws_credential_file'
knife[:aws_access_key_id]     = 'ALFJKJCFJFCJEFEFEC'
knife[:aws_secret_access_key] = 'CELFKNCKWJEFCURF/22lksjdc/wclfj/283/ikrfj'
knife[:identity_file]         = "#{current_dir}/.chef/new-iac-coe.pem"
knife[:ssh_key_name]          = 'chef-coe-ind-mind'
knife[:ssh_user]              = 'ubuntu'
knife[:winrm_port]            = '5985'
knife[:region]                = 'ap-south-1'
knife[:image]                 = 'ami-7c8ead13'
knife[:security_group_ids]    = 'launch-wizard-11'
knife[:ssh_port]              = 22

#------------------------azure  and openstack credentials--------------------------

knife[:azure_tenant_id] = "34lkfv4dklv3lk-3343242-14134er-vd123-a5e41061e661"
knife[:azure_subscription_id] = "34lkfv4dklv3lk-3343242-14134er-vd123-a5e41061e661"
knife[:azure_client_id] = "34lkfv4dklv3lk-3343242-14134er-vd123-a5e41061e661"
knife[:azure_client_secret] = "ceZBgXQoryOMGvK6txScc/TruRGaHucs9uayj8d/OtI="
knife[:azure_resource_group_name] = "Dengine"
knife[:azure_service_location] = "CentralIndia"

knife[:azure_image] = "ubuntu"

#---------------------openstack details----------------------------------
knife[:openstack_auth_url] = "https://sandbox.platform9.net/keystone/v2.0/tokens"
knife[:openstack_username] = "XXXXSS@gmail.com"
knife[:openstack_password] = "4XXXXXXXXXX24"
knife[:openstack_tenant] = "tenant-XXXXXXXXXXXXXXgmailcom"
knife[:openstack_region] = "US-West-KVM-01"

#knife[:ops_key]               = 'test_key'
knife[:network_ids]           = '957b9d64-a251-43a8-8716-8c6518e94861'
knife[:ops_image]             = 'bbdd7252-6298-d7ba-60ed-2d7454356ae1'

#-----------------------Google Cloud details-----------------------
knife[:gce_project] = "fit-aloe-179707"
knife[:gce_zone] = "us-central1-c"

knife[:gce_image] = "ubuntu-14-04"
#knife[:GOOGLE_APPLICATION_CREDENTIALS] = "/root/chef-repo/.chef/Project-ce1019e73f90.json"

#-------------------------------------------------------------------
#knife[:gateway_key] = "/var/lib/jenkins/chef-repo/.chef/google_key.ppk"
knife[:public_key]  = "/var/lib/jenkins/chef-repo/.chef/google_key"
```
