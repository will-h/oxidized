require 'spec_helper'
require 'oxidized/cli'

describe Oxidized::CLI do
  let(:asetus) { mock() }

  after  { ARGV.replace @original }
  before { @original = ARGV }

  %w[-v --version].each do |option|
    describe option do
      before { ARGV.replace [option] }

      it 'prints the version and exits' do
        Oxidized::Config.expects(:load)
        Oxidized.expects(:setup_logger)
        Kernel.expects(:exit)

        proc {
          Oxidized::CLI.new
        }.must_output "#{Oxidized::VERSION}\n"
      end
    end
  end
end
