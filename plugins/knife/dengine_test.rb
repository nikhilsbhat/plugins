require 'chef/knife'
require 'git'

module Engine
  class DengineGitTest < Chef::Knife

    banner "knife dengine git test (options)"

    def run
      Git.configure do |config|
        # If you need to use a custom SSH script
        config.git_ssh = '/root/chef-repo/.chef/wrap-ssh4git.sh'
      end
#      g = Git.clone('git@bitbucket.org:devopsiac/plugins.git', 'plugins2.0', :path => '/tmp/test_git')
      g = Git.clone('git@bitbucket.org:devopsiac/plugins.git', 'plugins2.0')
      g.pull
#      g = Git.open("/root/.chef", :log => Logger.new(STDOUT))
#      puts "#{g.describe('HEAD', {:all => true, :tags => true})}"
#      g.branches.local
    end

  end
end
