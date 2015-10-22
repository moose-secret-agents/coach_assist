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
        response = client.get "/users/#{username}", basic_auth: @auth
        response.code == 200 ? build(JSON.parse(response.body)) : nil
      end

      # Check whether user exists
      def exists?(username)
        !!find(username)
      end

      def authenticated?(username, password)
        authenticated(username, password) do
          response = client.get '/authenticateduser', basic_auth: @auth
          response.code == 200 ? build(JSON.parse(response.body)) : nil
        end
      end

      # Create new user
      def create(username, attributes={})
        response = client.put "/users/#{username}", body: attributes
        response.code == 201 ? build(JSON.parse(response.body)) : nil
      end

      def build(attributes={})
        u = Coach::User.new(attributes)
        u.set_client(client)
        u
      end
    end
  end
end