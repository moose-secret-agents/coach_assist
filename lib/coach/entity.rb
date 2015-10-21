module Coach
  class Entity < Hashie::Trash
    include Hashie::Extensions::IndifferentAccess
    include HTTParty

    debug_output $stdout
    format :json

    property :uri
    property :id
    property :created_at, from: :datecreated
    property :visibility, from: :publicvisible, default: 2

    headers  'Accept' => 'application/json'
    base_uri 'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources'

    class << self
      attr_accessor :auth

      def authenticated(username, password, &block)
        @auth = { username: username, password: password }
        res = instance_eval &block
        @auth = nil
        res
      end
    end

    # Fetch an entity based on its uri. Each entity containing a valid uri will be retrievable through this method
    def fetch
      return self if @fetched
      assert_has_uri!

      response = Entity.get clean_uri
      update_attributes! JSON.parse(response.body)

      @fetched = true
      self
    end

    def destroy
      assert_has_uri!
      Entity.delete clean_uri, basic_auth: self.class.auth
    end

    def update(attributes={})
      assert_has_uri!
      response = Entity.put clean_uri, body: attributes, basic_auth: self.class.auth
      update_attributes! JSON.parse(response.body) if response.code == 200
    end

    def fetched?
      !!@fetched
    end

    private
      # Remove overlapping url parts
      def clean_uri
        self.uri.gsub('/CyberCoachServer/resources', '')
      end

      def assert_has_uri!
        raise 'Entity has no URI associated with it' unless self.uri
      end
  end
end