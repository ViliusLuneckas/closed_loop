module ClosedLoop
  module Machine
    class Transition < Base
      def times_used
        @track_times_used ||= 0
      end

      def available?(target, user)
        role == machine.resolve_role(target, user) &&
          target.status.to_sym == from &&
          none_constraints?(target, user)
      end

      def none_constraints?(target, user)
        machine.configuration.select_constraints_for(self).all? do |constraint|
          constraint.allows?(target, user, transition: self)
        end
      end

      def perform!(target, user)
        target.class.transaction do
          target.status             = to
          target.last_transition_at = Time.current if target.respond_to?(:last_transition_at)

          proc&.call(target, user, transition: self)

          target.save!

          machine.configuration.select_callbacks_for(self).each do |callback|
            callback.perform!(target, user, transition: self)
          end

          raise 'Callback changes were not saved' if target.changed?

          yield(target, user, transition: self) if block_given?
        end

        @track_times_used = times_used + 1
      end
    end
  end
end
