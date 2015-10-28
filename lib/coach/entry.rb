module Coach
  class Entry < Coach::Entity

    property :modified_at, from: :datemodified
    property :subscription
    property :rounds, from: :numberofrounds
    property :distance, from: :courselength
    property :duration, from: :entryduration

    alias_method :subscription_orig, :subscription

    def subscription
      client.subscriptions.build(subscription_orig).fetch
    end
  end
end
