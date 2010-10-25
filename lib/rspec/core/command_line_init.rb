module RSpec
  module Core
    class CommandLineInit
      attr_reader :command

      def initialize(cmd = nil)
        @command = cmd
      end

      def run
        case @command
        when 'autotest' then Autotest.generate
        when nil then BasicFiles.generate
        else raise ArgumentError, <<-MESSAGE

#{"*"*50}
"#{@command}" is not valid a valid argument to "rspec init".
Supported options are:

  rspec --init           # generates basic .rspec and spec/spec_helper.rb files
  rspec --init autotest  # also generates configuration to run autotest with rspec

#{"*"*50}
MESSAGE
        end
      end

      class Autotest
        class << self
          def generate
            create_autotest_directory
            create_discover_file
          end

          def create_autotest_directory
            Dir.mkdir('autotest') unless File.exist?('autotest')
          end

          def create_discover_file
            optionally_remove_discover_file if discover_file_exists?
            File.open(discover_file_path, 'w') do |file|
              file << 'Autotest.add_discovery { "rspec2" }'
            end
            puts "autotest/discover.rb has been added"
          end

          def optionally_remove_discover_file
            print "Discover file already exists, overwrite [y/N]? "
            exit if gets !~ /y/i
            FileUtils.rm_rf(discover_file_path)
          end

          def discover_file_exists?
            File.exist?(discover_file_path)
          end

          def discover_file_path
            File.join('autotest', 'discover.rb')
          end
        end
      end

      class BasicFiles
        class << self
          def generate
            create_dot_rspec_file
            create_spec_directory
            create_spec_helper_file
          end

          def create_spec_directory
            Dir.mkdir('spec') unless File.exist?('spec')
          end

          def create_dot_rspec_file
            optionally_remove_dot_rspec_file if dot_rspec_file_exists?
            File.open(dot_rspec_file_path, 'w') do |file|
              file << "--colour\n"
              file << '--format documentation'
            end
            puts ".rspec has been added"
          end

          def create_spec_helper_file
            optionally_remove_spec_helper_file if spec_helper_file_exists?
            File.open(spec_helper_file_path, 'w') do |file|
              file << "$LOAD_PATH.unshift(File.dirname(__FILE__))\n"
              file << "$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))\n" if File.exist?('lib')
              file << "\n"
              file << "require 'rspec'\n"
              file << "require 'rspec/autorun'"
            end
            puts "spec/spec_helper.rb has been added"
          end

          def optionally_remove_dot_rspec_file
            print ".rspec file already exists, overwrite [y/N]? "
            exit if gets !~ /y/i
            FileUtils.rm_rf(dot_rspec_file_path)
          end

          def dot_rspec_file_exists?
            File.exist?(dot_rspec_file_path)
          end

          def dot_rspec_file_path
            File.join('.rspec')
          end

          def optionally_remove_spec_helper_file
            print "spec/spec_helper.rb file already exists, overwrite [y/N]? "
            exit if gets !~ /y/i
            FileUtils.rm_rf(spec_helper_file_path)
          end

          def spec_helper_file_exists?
            File.exist?(spec_helper_file_path)
          end

          def spec_helper_file_path
            File.join('spec','spec_helper.rb')
          end
        end
      end
    end
  end
end
