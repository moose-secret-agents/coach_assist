module Coach
  module Finders
    class Finder
      attr_accessor :client

      def initialize(client)
        @client = client
      end
    end
  end
end