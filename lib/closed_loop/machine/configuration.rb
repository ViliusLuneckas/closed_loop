module ClosedLoop
  module Machine
    class Configuration
      attr_reader :transitions, :callbacks, :machine, :constraints

      def initialize(machine)
        @machine     = machine
        @transitions = []
        @callbacks   = []
        @constraints = []
      end

      def transition(config, &block)
        @transitions << Transition.new(config.merge(machine: machine), block)
      end

      def callback(config, &block)
        @callbacks << Callback.new(config.merge(machine: machine), block)
      end

      def constraint(config, &block)
        @constraints << Constraint.new(config.merge(machine: machine), block)
      end

      def select_callbacks_for(transition)
        @callbacks.select do |callback|
          (callback.from.nil? || Array(callback.from).include?(transition.from)) &&
            (callback.to.nil? || Array(callback.to).include?(transition.to))
        end
      end

      def select_constraints_for(transition)
        @constraints.select do |constraint|
          (constraint.from.nil? || Array(constraint.from).include?(transition.from)) &&
            (constraint.to.nil? || Array(constraint.to).include?(transition.to)) &&
            (constraint.role == transition.role)
        end
      end
    end
  end
end
