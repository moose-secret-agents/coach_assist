module Coach
  module Finders
    class EntryFinder < Finder

      def all(username, sport, options={})
        eager = options[:eager]
        response = client.get "/users/#{username}/#{sport}", query: { start: 0, size: 10000 }
        JSON.parse(response.body)['entries'].map { |e| eager ? build(e).fetch : build(e) }
      end

      def find(username, sport)
        response = client.get "/users/#{username}/#{sport}/"
        build(JSON.parse(response.body))
      end

      def create(username, sport, attributes={})
        client.assert_authenticated!

        body = { "entry#{sport}".to_s => attributes }
        response = client.post "/users/#{username}/#{sport}", body: body.to_json, headers: {'Content-Type' => 'application/json'}
        response.code.in?([200, 201]) ? build(JSON.parse(response.body).merge(uri: response.response['Location'])).fetch : nil
      end

      def build(attributes={})
        attrs = attributes['entryrunning'] || attributes['entrycycling'] || attributes

        e = Coach::Entry.new(attrs)
        e.set_client client
        e
      end

    end
  end
end