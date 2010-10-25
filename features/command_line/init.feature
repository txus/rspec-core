Feature: init
  
  Use the rspec --init command on the command line to generate a basic
  structure for a RSpec project.

  This command will generate a .rspec file in your project root directory
  and a spec_helper.rb file inside the spec/ folder with some basic defaults.

  Using it with `autotest` option will create an autotest/discover.rb file
  in your project root directory.

  Background:
    Given a directory named "rspec_project"

  Scenario: generate spec_helper and .rspec file
    Given a directory named "rspec_project/lib"
    When I cd to "rspec_project"
    And I run "rspec --init"
    Then the following directories should exist:
      | spec |
    And the following files should exist:
      | .rspec |
      | spec/spec_helper.rb |
    And the file ".rspec" should contain "--colour"
    And the file ".rspec" should contain "--format documentation"
    And the file "spec/spec_helper.rb" should contain "$LOAD_PATH.unshift(File.dirname(__FILE__))"
    And the file "spec/spec_helper.rb" should contain "$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))"
    And the file "spec/spec_helper.rb" should contain "require 'rspec'"
    And the file "spec/spec_helper.rb" should contain "require 'rspec/autorun'"
    And the stdout should contain ".rspec has been added"
    And the stdout should contain "spec/spec_helper.rb has been added"
    
  Scenario: with --autotest option
    When I cd to "rspec_project"
    And I run "rspec --init autotest"
    Then the following directories should exist:
      | autotest |
    And the following files should exist:
      | autotest/discover.rb |
    And the file "autotest/discover.rb" should contain "Autotest.add_discovery"
    And the stdout should contain "autotest/discover.rb has been added"
