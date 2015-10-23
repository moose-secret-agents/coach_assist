module Coach
  module Finders
    class UserFinder < Finder

      # Find all users on server. Pass :eager option to return results eagerly (slow)
      # Pass :search option to only include users matching the search query
      def all(options={})
        eager, search = options.values_at(:eager, :search)
        response = client.get '/users', query: { start: 0, size: 10000, searchCriteria: search }
        JSON.parse(response.body)['users'].map { |u| eager ? build(u).fetch : build(u) }
      end

      # Find user by username
      def find(username)
        response = client.get "/users/#{username}"
        response.code == 200 ? build(JSON.parse(response.body)) : nil
      end

      # Check whether user exists
      def exists?(username)
        !!find(username)
      end

      def authenticated?(username, password)
        authenticated(username, password) do
          response = client.get '/authenticateduser'
          response.code == 200 ? build(JSON.parse(response.body)) : nil
        end
      end

      # Create new user
      def create(username, attributes={})
        response = client.put "/users/#{username}", body: attributes
        [200, 201].include?(response.code) ? build(JSON.parse(response.body)) : nil
      end

      def find_or_create(username, attributes={})
        u = find(username)
        u || create(username, attributes)
      end

      def build(attributes={})
        u = Coach::User.new(attributes)
        u.set_client(client)
        u
      end
    end
  end
end