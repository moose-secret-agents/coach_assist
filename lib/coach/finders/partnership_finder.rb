module Coach
  module Finders
    class PartnershipFinder < Finder
      def all
        eager, search = options.values_at(:eager, :search)
        response = client.get '/partnerships', query: { start: 0, size: 10000, searchCriteria: search }
        JSON.parse(response.body)['partnerships'].map { |ps| eager ? build(ps).fetch : build(ps) }
      end

      def find(username1, username2)
        response = client.get "/partnerships/#{username1};#{username2}"
        response.code == 200 ? build(JSON.parse(response.body)) : nil
      end

      def exists?(username1, username2)
        !!find(username1, username2)
      end

      def create(username1, username2, attributes={})
        response = client.put "/partnerships/#{username1};#{username2}", body: attributes
        response.code == 201 ? build(JSON.parse(response.body)) : nil
      end

      def build(attributes={})
        u = Coach::Partnership.new(attributes)
        u.set_client(client)
        u
      end
    end
  end
end