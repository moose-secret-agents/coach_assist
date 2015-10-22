module Coach
  module Finders
    class SubscriptionFinder < Finder
      def build(attributes={})
        u = Coach::Subscription.new(attributes)
        u.set_client(client)
        u
      end
    end
  end
end