RSpec.describe ClosedLoop::Machine::Instance do
  subject do
    class StateMachine < described_class

      def configure_all
      end
    end

    StateMachine.new
  end

  describe 'configuration' do
    it 'accepts' do
      expect(subject.configuration).to be_a(ClosedLoop::Machine::Configuration)
    end
  end

  it "has a version number" do
    expect(ClosedLoop::VERSION).not_to be nil
  end
end
