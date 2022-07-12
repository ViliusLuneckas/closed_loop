module ClosedLoop
  module Machine
    class Constraint < Base
      def allows?(*args)
        proc.call(*args)
      end
    end
  end
end
