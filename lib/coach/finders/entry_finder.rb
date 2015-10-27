module Coach
  module Finders
    class EntryFinder < Finder

      def all(username, sport, options={})
        eager = options.values_at(:eager)
        response = client.get "/users/#{username}/#{sport}", query: { start: 0, size: 10000 }
        JSON.parse(response.body)['entries'].map { |e| eager ? build(e).fetch : build(e) }
      end

      def find(username, sport)
        response = client.get "/users/#{username}/#{sport}/"
        build(JSON.parse(response.body))
      end

      def build(attributes={})
        attrs = (attributes['entryrunning'] || {}).merge(attributes['entrycycling'])

        e = Coach::Entry.new(attrs)
        e.set_client client
        e
      end

    end
  end
end