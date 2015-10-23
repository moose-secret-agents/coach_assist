module Coach
  class Entity < Hashie::Trash
    include Hashie::Extensions::IndifferentAccess

    attr_accessor :client

    property :uri
    property :id
    property :created_at, from: :datecreated
    property :visibility, from: :publicvisible, default: 2

    # Fetch an entity based on its uri. Each entity containing a valid uri will be retrievable through this method
    def fetch
      assert_has_uri!

      response = client.get clean_uri
      update_attributes! JSON.parse(response.body)

      self
    end

    def destroy
      assert_has_uri!
      client.delete clean_uri
    end

    def update(attributes={})
      assert_has_uri!
      response = client.put clean_uri, body: attributes
      update_attributes! JSON.parse(response.body) if response.code == 200
    end

    def set_client(client)
      self.client = client
      self
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