module ClosedLoop
  module Machine
    class RoleResolver
      attr_reader :target, :user

      def initialize(target, user)
        @target = target
        @user   = user
      end
    end
  end
end
