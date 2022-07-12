module ClosedLoop
  module Machine
    class Callback < Base
      def perform!(target, user, options)
        proc&.call(target, user, options)
      end
    end
  end
end
