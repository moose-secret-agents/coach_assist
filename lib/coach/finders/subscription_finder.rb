module Coach
  module Finders
    class SubscriptionFinder < Finder

      def find(username, sport)
        response = client.get "/users/#{username}/#{sport}"
        response.code == 200 ? build(JSON.parse(response.body)) : nil
      end

      def exists?(username1, username2)
        !!find(username1, username2)
      end

      def create(username, sport, attributes={})
        response = client.put "/users/#{username}/#{sport}", body: attributes
        response.code == 201 ? build(JSON.parse(response.body)) : nil
      end

      def build(attributes={})
        s = Coach::Subscription.new(attributes)
        s.set_client(client)
        s
      end

    end
  end
end