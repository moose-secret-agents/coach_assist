module Coach
  class Subscription < Coach::Entity
    property :datesubscribed
    property :sport
    property :user
    property :entries

    alias_method :user_orig, :user
    alias_method :entries_orig, :entries

    def user
      client.users.build(user_orig).fetch
    end

    def self.types
      [:running, :cycling]
    end

    def entries
      (entries_orig || []).map { |e| client.entries.build(e) }
    end
  end
end
