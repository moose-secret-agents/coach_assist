module Coach
  module Finders
    class PartnershipFinder < Finder
      def build(attributes={})
        u = Coach::Partnership.new(attributes)
        u.set_client(client)
        u
      end
    end
  end
end