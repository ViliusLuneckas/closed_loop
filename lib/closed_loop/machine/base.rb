module ClosedLoop
  module Machine
    class Base
      ATTRIBUTES = %i[machine to from role].freeze

      attr_reader(*(ATTRIBUTES + [:proc]))

      def initialize(config, proc = nil)
        config.slice(*ATTRIBUTES).each { |k, v| instance_variable_set("@#{k}", v) }

        @proc = proc
      end
    end
  end
end
