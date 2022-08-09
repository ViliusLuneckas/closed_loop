require 'forwardable'

module ClosedLoop
  module Machine
    class Instance
      extend Forwardable

      attr_reader :configuration

      def_delegators :@configuration, :transition, :callback, :constraint

      def initialize
        @configuration = ClosedLoop::Machine::Configuration.new(self)

        configure_all
      end

      def available_transitions(target, user)
        configuration.transitions.select { |transition| transition.available?(target, user) }
      end

      def transition!(target, user, to:, &block)
        available_transition = available_transitions(target, user).find do |transition|
          transition.from == target.status.to_sym && transition.to == to.to_sym
        end

        if available_transition&.available?(target, user)
          available_transition.perform!(target, user, &block)
        else
          raise("Transition #{self.class} #{target.status}->#{to} for #{target.id} by #{user} not available!")
        end
      end

      def resolve_role(*args)
        self.class.const_get('RoleResolver').new(*args).call
      end

      def configure_all
        raise '#configure_all not implemented yet'
      end
    end
  end
end
