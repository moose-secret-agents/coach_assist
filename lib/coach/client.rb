module Coach
  class Client
    include HTTParty

    debug_output $stdout
    format :json

    headers  'Accept' => 'application/json'
    base_uri 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources'

    def get(path, options={})
      Client.get(path, options.merge(basic_auth: @auth))
    end

    def post(path, options={})
     Client.post(path, options.merge(basic_auth: @auth))
    end

    def put(path, options={})
      Client.put(path, options.merge(basic_auth: @auth))
    end

    def delete(path, options={})
      Client.delete(path, options.merge(basic_auth: @auth))
    end

    def authenticate(username, password)
      @auth = { username: username, password: password }
    end

    def authenticated(username, password, &block)
      authenticate(username, password)
      block.call
      @auth = nil
    end

    def has_auth?
      !!@auth
    end

    def users
      @user_finder || (@user_finder = Finders::UserFinder.new(self))
    end

    def partnerships
      @ps_finder || (@ps_finder = Finders::PartnershipFinder.new(self))
    end

    def subscriptions
      @sub_finder || (@sub_finder = Finders::SubscriptionFinder.new(self))
    end

  end
end
