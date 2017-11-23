require 'chef/knife'

module Engine
  class DengineSyntaxCheck < Chef::Knife

    banner "knife dengine syntax check (options)"

    option :environments,
      :short => '-e',
      :long => '--environments',
      :boolean => true,
      :description => "Test only environment syntax"
    option :roles,
      :short => '-r',
      :long => '--roles',
      :boolean => true,
      :description => "Test only role syntax"
    option :nodes,
      :short => '-n',
      :long => '--nodes',
      :boolean => true,
      :description => "Test only node syntax"
    option :databags,
      :short => '-D',
      :long => '--databags',
      :boolean => true,
      :description => "Test only databag syntax"
    option :cookbooks,
      :short => '-c',
      :long => '--cookbooks',
      :boolean => true,
      :description => "Test only cookbook syntax"
    option :all,
      :short => '-a',
      :long => '--all',
      :boolean => true,
      :description => "Test syntax of all roles, environments, nodes, databags and cookbooks"

    deps do
      require 'yajl'
      require 'pathname'
      require 'chef/knife/cookbook_test'
      Chef::Knife::CookbookTest.load_deps
      require 'foodcritic'
      require 'foodcritic/command_line'
#      FoodCritic::CommandLine.load_deps
    end

    def run
      if config[:roles]
        test_object("/root/chef-repo/roles/*", "role")
      elsif config[:environments]
        test_object("/root/chef-repo/environments/*", "environment")
      elsif config[:nodes]
        test_object("/root/chef-repo/nodes/*", "node")
      elsif config[:databags]
        test_databag("/root/chef-repo/data_bags/*", "data bag")
      elsif config[:cookbooks]
        test_cookbooks()
      elsif config[:all]
        test_object("/root/chef-repo/roles/*", "role")
        test_object("/root/chef-repo/environments/*", "environment")
        test_object("/root/chef-repo/nodes/*", "node")
        test_databag("/root/chef-repo/data_bags/*", "data bag")
        test_plugins("/root/.chef/**/*", "plugins")
#        test_plugins("/root/chef-repo/*", "plugins")
        test_cookbooks("/root/chef-repo/cookbooks")
        foodcritic()
      else
        ui.msg("Usage: knife dengine syntax check --help")
      end
    end

    # Test all cookbooks
    def test_cookbooks(path)
      ui.msg("Testing all cookbooks...")
      test_cookbook = Chef::Knife::CookbookTest.new
      test_cookbook.config[:all] = "-a"
      test_cookbook.config[:cookbook_path] = path
      test_cookbook.run
    end

    # Test object syntax
    def test_object(dirname,type)
      ui.msg("Finding type #{type} to test from #{dirname}")
      check_syntax(dirname,nil,type)
    end

    # Test plugin syntax
    def test_plugins(dirname,type)
      ui.msg("Finding type #{type} to test from #{dirname}")
      check_syntax(dirname,nil,type)
    end


    # Test databag syntax
    def test_databag(dirname, type)
      ui.msg("Finding type #{type} to test from #{dirname}")
      dirs = Dir.glob(dirname).select { |d| File.directory?(d) }
      dirs.each do |directory|
        dir = Pathname.new(directory).basename
        check_syntax("#{directory}/*", dir, type)
      end
    end

    # Common method to test file syntax
    def check_syntax(dirpath, dir = nil, type)
      files = Dir.glob("#{dirpath}").select { |f| File.file?(f) }
      files.each do |file|
        fname = Pathname.new(file).basename
        if ("#{fname}".end_with?('.json'))
          ui.msg("Testing file #{file}")
          json = File.new(file, 'r')
          parser = Yajl::Parser.new
          hash = parser.parse(json)
        elsif("#{fname}".end_with?('.rb'))
          ui.msg("Testing file #{file}")
          cmd = Mixlib::ShellOut.new("ruby -c #{file}")
          cmd.run_command
#          puts cmd.stdout
          @error_ruby = cmd.stderr
          if (!@error_ruby.empty?) && ("#{fname}".end_with?('.rb'))
            raise RubySyntaxError.new("Ruby Syntax Is not Happy", "ERROR:")
          end
        end
      end 
      if !@error_ruby.nil?
        puts "."
         puts "Kudos syntaxes of Ruby files for #{type} are great....We are good to go ahead"
        puts "."
      end
    end

    def foodcritic()
      ["/root/chef-repo/roles","/root/chef-repo/cookbooks","/root/chef-repo/environments"].each do |path|
        puts ""
        puts "I am checking the standards for #{path}"
        puts ""
        [01,02,04,05,06,07,10,13,16,19,24,25,26,27,28,29,31,32,33,34,38,39,40,41,42,43,44,45,48,49,50,51,61,66,74,77,82,86,88,89,92,94,95,98].each do |rule_no|
          foodcritic_check(rule_no.to_s,path)
        end
      end
    end
	
    def foodcritic_check(rule_no,path)
      if path.include? "roles"
        type = "-R"
      elsif path.include? "cookbooks"
        type = "-t FC0#{rule_no}"
      elsif path.include? "environments"
        type = "-E"
      else
        puts "Could not get valid type"
      end
      cmd = Mixlib::ShellOut.new("foodcritic #{type} #{path}")
      cmd.run_command
      puts cmd.stdout
      @error_food = cmd.stderr
      if !@error_food.empty?
        raise FoodCriticError.new("FoodCritic Is not Happy", "ERROR:")
          puts @error_food
      end
    end

  end

  class FoodCriticError < StandardError
    attr_reader :error

    def initialize(msg="FoodCritic Is not Happy", error="ERROR:")
      @error = error
      super(msg)
    end
  end

  class RubySyntaxError < StandardError
    attr_reader :error

    def initialize(msg="Ruby Syntax Is not Happy", error="ERROR:")
      @error = error
      super(msg)
    end
  end

end
