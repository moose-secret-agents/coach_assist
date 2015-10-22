module Coach
  class User < Coach::Entity

    property :username
    property :password
    property :real_name, from: :realname
    property :email
    property :partnerships, default: []
    property :subscriptions, default: []

    alias_method :partnerships_orig, :partnerships
    alias_method :subscriptions_orig, :subscriptions

    def partnerships
      (partnerships_orig || []).map { |p| client.partnerships.build(p).fetch }
    end

    def subscriptions
      (subscriptions_orig || []).map { |p| client.subscriptions.build(p).fetch }
    end

    def pending_partnerships
      partnerships.select { |ps| ps.user2.username == self.username && !ps.confirmed_by_user2}
    end

    def confirm_partnership(ps)
      ps.confirm
    end
  end
end