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

    def subscribe_to(sport)
      raise 'Can only subscribe to :running or :cycling' unless Coach::Subscription.types.include? sport.to_sym
      client.subscriptions.create(self.username, sport, publicvisible: 2)
    end

    def destroy
      destroy_partnerships
      destroy_subscriptions
      super
    end


      def destroy_partnerships
        partnerships.each(&:destroy)
      end

      def destroy_subscriptions
        subscriptions.each(&:destroy)
      end
  end
end