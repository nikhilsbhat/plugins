require 'aws-sdk'
require 'chef/knife'
require 'chef/knife/ec2_base'

class Chef
  class Knife
    class Ec2DataBag < Chef::Knife

        banner "knife data bag test"

		def run
			list_bag = Chef::DataBag.list
			users = Chef::DataBag.new
			users.name('users')
			users.create	
			sam = {
			  'id' => 'sam',
			  'Full Name' => 'Sammy',
			  'shell' => '/bin/zsh'
			}
			databag_item = Chef::DataBagItem.new
			databag_item.data_bag('users')
			databag_item.raw_data = sam
			databag_item.save
		end
    end
  end
end

