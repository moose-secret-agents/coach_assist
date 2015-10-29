require 'spec_helper'

RSpec.describe 'CoachAPI', type: :model do

  before(:each) do
    @coach = Coach::Client.new
    @coach.authenticate('housi', 'housi') { @coach.users.find('housi').try(:destroy) }
  end

  after(:each) do
    @coach.authenticate('housi', 'housi') { @coach.users.find('housi').try(:destroy) }
  end

  context 'Users' do
    it 'authenticates user' do
      expect(@coach.users.authenticated?('trackingtest', 'trackingtest')).to be true
    end

    it 'returns authenticated user' do
      expect(@coach.users.authenticated('trackingtest', 'trackingtest')).to be_a Coach::User
    end

    it 'returns list of all users' do
      expect { @coach.users.all }.to_not raise_error
    end

    it 'lists all users' do
      expect(@coach.users.all.count).to be > 5
    end

    it 'should find newuser1' do
      expect(@coach.users.find('newuser1')).to be_truthy
    end

    it 'can search for usernames' do
      results = @coach.users.all(search: 'newuser1')

      expect(results).to be_truthy
      expect(results.count).to be > 0
      #expect(results.map(&:fetch)).to include @client.users.find('newuser1')
    end

    it 'should have accessible partnerships' do
      user = @coach.users.find('newuser1')
      expect { user.partnerships }.to_not raise_error
    end

    it 'should have accessible subscriptions' do
      user = @coach.users.find('newuser1')
      expect { user.subscriptions }.to_not raise_error
    end

    it 'should return partnerships with correct type' do
      user = @coach.users.find('newuser1')
      expect(user.partnerships.first).to be_a Coach::Partnership
    end

    it 'should return subscription with correct type' do
      user = @coach.users.find('newuser1')
      expect(user.subscriptions.first).to be_a Coach::Subscription
    end

    it 'should equal the user of its subscription' do
      user = @coach.users.find('newuser1')
      expect(user.subscriptions.first.user).to eq user
    end

    it 'should equal one user of its partnership' do
      user = @coach.users.find('newuser1')
      partnership = user.partnerships.first

      expect(partnership.users).to include user
    end

    it 'can delete user via model' do
      @coach.authenticate('housi', 'housi')

      user = @coach.users.find_or_create('housi', password: 'housi', email: 'test@housi.ch', realname: 'housi', publicvisible: 2)

      expect { user.destroy }.to_not raise_error
      expect(@coach.users.exists?('housi')).to be false
    end

    it 'can modify user via model' do
      @coach.authenticated('housi', 'housi') do
        @coach.users.find('housi').destroy if @coach.users.exists?('housi')
        user = @coach.users.create('housi', password: 'housi', email: 'test@housi.ch', realname: 'housi', publicvisible: 2)

        expect(user.real_name).to eq('housi')

        expect {
          user.update realname: 'housinew'
        }.to_not raise_error

        expect(user.real_name).to eq 'housinew'
      end
    end

    it 'can update model from other client' do
      client1 = Coach::Client.new
      client2 = Coach::Client.new

      user = client1.users.find('housi')

      client1.authenticated('housi','housi') do
        user.destroy if user
      end

      expect(client1.has_auth?).to be_falsey

      user = client2.users.create('housi', password: 'housi', email: 'test@housi.ch', realname: 'housi', publicvisible: 2)

      expect(user.real_name).to eq('housi')

      client2.authenticated('housi', 'housi') do
        user.update(realname: 'Housi Zumbrunn')
      end

      expect(client2.has_auth?).to be_falsey

      expect(user.real_name).to eq('Housi Zumbrunn')

    end

    it 'can create new user' do
      user = @coach.users.create('housi', password: 'housi', email: 'test@housi.ch', realname: 'housi', publicvisible: 2)
      expect(user.username).to eq('housi')
    end

  end

  context 'Partnerships' do

    before(:each) do
      @coach.authenticated('testaschi', 'testaschi') { @coach.users.find('testaschi').try(:destroy) }
      @coach.authenticated('testguschti', 'testguschti') { @coach.users.find('testguschti').try(:destroy) }

      @aschi = @coach.users.find_or_create('testaschi', password: 'testaschi', email: 'testaschi@testaschi.testaschi',
                                   realname: 'testaschi Hunziker', publicvisible: 2)
      @guschti = @coach.users.find_or_create('testguschti', password: 'testguschti', email: 'guschti@guschti.guschti',
                                             realname: 'Guschti Kyburz', publicvisible: 2)
    end

    after(:each) do
      @coach.authenticated('testaschi', 'testaschi') { @coach.users.find('testaschi').try(:destroy) }
      @coach.authenticated('testguschti', 'testguschti') { @coach.users.find('testguschti').try(:destroy) }
    end

    it 'can create partnership' do
      @coach.authenticated('testaschi', 'testaschi') do
        @ps = @coach.partnerships.create(@aschi.username, @guschti.username, publicvisible: 2)

        expect(@coach.partnerships.exists?('testaschi', 'testguschti')).to be_truthy
        expect(@ps.user1.username).to eq('testaschi')
        expect(@ps.user2.username).to eq('testguschti')
        expect(@ps.confirmed_by_user1).to be(true)
        expect(@ps.confirmed_by_user2).to be(false)
        expect(@ps.user1.partnerships.first.user1.username).to eq('testaschi')

        @aschi.fetch
        @guschti.fetch

        expect(@aschi.partnerships.size).to be > 0
        expect(@guschti.partnerships.size).to be > 0

        expect(@aschi.pending_partnerships.size).to be 0
        expect(@guschti.pending_partnerships.size).to be 1
      end

      @coach.authenticated('testguschti', 'testguschti') do
        @guschti.confirm_partnership(@ps)

        expect(@ps.fetch.confirmed_by_user2).to be(true)
      end

    end
  end

  context 'Subscriptions' do

    before(:each) do
      @coach.authenticated('testaschi', 'testaschi') { @coach.users.find('testaschi').try(:destroy) }
      @coach.authenticated('testguschti', 'testguschti') { @coach.users.find('testguschti').try(:destroy) }

      @aschi = @coach.users.find_or_create('testaschi', password: 'testaschi', email: 'testaschi@testaschi.testaschi',
                                           realname: 'testaschi Hunziker', publicvisible: 2)
      @guschti = @coach.users.find_or_create('testguschti', password: 'testguschti', email: 'guschti@guschti.guschti',
                                             realname: 'Guschti Kyburz', publicvisible: 2)
    end

    after(:each) do
      @coach.authenticated('testaschi', 'testaschi') { @coach.users.find('testaschi').try(:destroy) }
      @coach.authenticated('testguschti', 'testguschti') { @coach.users.find('testguschti').try(:destroy) }
    end

    it 'should create a subscription for user' do
      expect(@guschti.subscriptions.count).to be 0

      @coach.authenticated('testguschti', 'testguschti') do
        @guschti.subscribe_to(:cycling)
      end

      expect(@guschti.fetch.subscriptions.count).to be 1
    end
  end

end
