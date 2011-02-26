require 'spec_helper'

describe RSpec::Core::Example, :parent_metadata => 'sample' do
  let(:example_group) do
    RSpec::Core::ExampleGroup.describe('group description')
  end

  let(:example_instance) do
    example_group.example('example description')
  end

  it_behaves_like "metadata hash builder" do
    def metadata_hash(*args)
      example = example_group.example('example description', *args)
      example.metadata
    end
  end

  describe '#described_class' do
    it "returns the class (if any) of the outermost example group" do
      described_class.should == RSpec::Core::Example
    end
  end

  describe "accessing metadata within a running example" do
    it "has a reference to itself when running" do
      example.description.should == "has a reference to itself when running"
    end

    it "can access the example group's top level metadata as if it were its own" do
      example.example_group.metadata.should include(:parent_metadata => 'sample')
      example.metadata.should include(:parent_metadata => 'sample')
    end
  end

  describe "accessing options within a running example" do
    it "can look up option values by key", :demo => :data do
      example.options[:demo].should == :data
    end
  end

  describe "#run" do
    it "runs after(:each) when the example passes" do
      after_run = false
      group = RSpec::Core::ExampleGroup.describe do
        after(:each) { after_run = true }
        example('example') { 1.should == 1 }
      end
      group.run
      after_run.should be_true, "expected after(:each) to be run"
    end

    it "runs after(:each) when the example fails" do
      after_run = false
      group = RSpec::Core::ExampleGroup.describe do
        after(:each) { after_run = true }
        example('example') { 1.should == 2 }
      end
      group.run
      after_run.should be_true, "expected after(:each) to be run"
    end

    it "runs after(:each) when the example raises an Exception" do
      after_run = false
      group = RSpec::Core::ExampleGroup.describe do
        after(:each) { after_run = true }
        example('example') { raise "this error" }
      end
      group.run
      after_run.should be_true, "expected after(:each) to be run"
    end

    context "with an after(:each) that raises" do
      it "runs subsequent after(:each)'s" do
        after_run = false
        group = RSpec::Core::ExampleGroup.describe do
          after(:each) { after_run = true }
          after(:each) { raise "FOO" }
          example('example') { 1.should == 1 }
        end
        group.run
        after_run.should be_true, "expected after(:each) to be run"
      end

      it "stores the exception" do
        group = RSpec::Core::ExampleGroup.describe
        group.after(:each) { raise "FOO" }
        example = group.example('example') { 1.should == 1 }

        group.run

        example.metadata[:execution_result][:exception].message.should == "FOO"
      end
    end

    it "wraps before/after(:each) inside around" do
      results = []
      group = RSpec::Core::ExampleGroup.describe do
        around(:each) do |e|
          results << "around (before)"
          e.run
          results << "around (after)"
        end
        before(:each) { results << "before" }
        after(:each) { results << "after" }
        example { results << "example" }
      end

      group.run
      results.should eq([
        "around (before)",
        "before",
        "example",
        "after",
        "around (after)"
      ])
    end
  end

  describe "#pending" do
    context "in the example" do
      it "sets the example to pending" do
        group = RSpec::Core::ExampleGroup.describe do
          example { pending }
        end
        group.run
        group.examples.first.should be_pending
      end

      it "allows post-example processing in around hooks (see https://github.com/rspec/rspec-core/issues/322)" do
        blah = nil
        group = RSpec::Core::ExampleGroup.describe do
          around do |example|
            example.run
            blah = :success
          end
          example { pending }
        end
        group.run
        blah.should be(:success)
      end
    end
      
    context "in before(:each)" do
      it "sets each example to pending" do
        group = RSpec::Core::ExampleGroup.describe do
          before(:each) { pending }
          example {}
          example {}
        end
        group.run
        group.examples.first.should be_pending
        group.examples.last.should be_pending
      end
    end

    context "in before(:all)" do
      it "sets each example to pending" do
        group = RSpec::Core::ExampleGroup.describe do
          before(:all) { pending }
          example {}
          example {}
        end
        group.run
        group.examples.first.should be_pending
        group.examples.last.should be_pending
      end
    end

    context "in around(:each)" do
      it "sets the example to pending" do
        group = RSpec::Core::ExampleGroup.describe do
          around(:each) { pending }
          example {}
        end
        group.run
        group.examples.first.should be_pending
      end
    end

  end
end
