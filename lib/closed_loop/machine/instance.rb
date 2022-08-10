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

      def transit!(target, user, to:, &block)
        transition = find_transition(target, user, to:)

        unless transition
          raise("Transition #{self.class} #{target.status}->#{to} for #{target.id} by #{user} not available!")
        end

        transition.perform!(target, user, &block)
      end

      def transit(target, user, to:, attributes: {}, &block)
        transition = find_transition(target, user, to:)
        transition&.perform(target, user, attributes, &block)
      end

      def find_transition(target, user, to:)
        available_transitions(target, user).find { |transition| transition.to == to.to_sym }
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
