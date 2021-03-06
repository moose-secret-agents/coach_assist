module Coach
  class Partnership < Coach::Entity
    property :confirmed_by_user1, from: :userconfirmed1
    property :confirmed_by_user2, from: :userconfirmed2
    property :user1
    property :user2
    property :subscriptions

    alias_method :old_user1, :user1
    alias_method :old_user2, :user2
    alias_method :subscriptions_orig, :subscriptions

    def user1
      client.users.build(old_user1).fetch
    end

    def user2
      client.users.build(old_user2).fetch
    end

    def users
      [user1, user2]
    end

    def subscriptions
      (subscriptions_orig || []).map { |s| client.subscriptions.build(s).fetch }
    end

    def confirm
      client.assert_authenticated!
      client.put clean_uri
    end
  end
end
