module ClosedLoop
  module Machine
    class Transition < Base
      def times_used
        @track_times_used ||= 0
      end

      def available?(target, user)
        Array(role).include?(machine.resolve_role(target, user)) &&
          Array(from).include?(target.status.to_sym) &&
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

      def perform(target, user, attributes)
        target.class.transaction do
          target.assign_attributes(attributes)
          target.status             = to
          target.last_transition_at = Time.current if target.respond_to?(:last_transition_at)

          if target.save
            proc&.call(target, user, transition: self)

            machine.configuration.select_callbacks_for(self).each do |callback|
              callback.perform!(target, user, transition: self)
            end

            yield(target, user, transition: self) if block_given?
          end
        end

        @track_times_used = times_used + 1
      end
    end
  end
end
