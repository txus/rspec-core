require 'spec_helper'

module RSpec::Core
  describe CommandLineInit do
    describe '#run' do
      context 'given no commands' do
        let(:config) { CommandLineInit.new }

        it 'calls BasicFiles.generate' do
          CommandLineInit::BasicFiles.should_receive(:generate)
          config.run
        end

      end

      context 'given autotest command' do
        let(:config) { CommandLineInit.new('autotest') }

        it 'calls Autotest.generate' do
          CommandLineInit::Autotest.should_receive(:generate)
          config.run
        end

      end

      context 'given unsupported command' do
        let(:config) { CommandLineInit.new('unsupported') }

        it 'raises ArgumentError' do
          lambda { config.run }.should(
            raise_error(ArgumentError, /"unsupported" is not valid/)
          )
        end
      end
    end
  end
end
