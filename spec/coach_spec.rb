require 'spec_helper'

RSpec.describe 'CoachAPI', type: :model do

  before(:each) do
    @coach = Coach::Client.new
  end

  context 'Users' do
    
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

      user = if @coach.users.exists?('housi')
               @coach.users.find('housi')
             else
               @coach.users.create('housi', password: 'housi', email: 'test@housi.ch', realname: 'housi', publicvisible: 2)
             end

      expect { user.destroy }.to_not raise_error
      expect(@coach.users.exists?('housi')).to be_falsey
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
      @coach.authenticated('housi', 'housi') do
        @coach.users.find('housi').destroy if @coach.users.exists?('housi')
        user = @coach.users.create('housi', password: 'housi', email: 'test@housi.ch', realname: 'housi', publicvisible: 2)

        expect(user.username).to eq('housi')
      end
    end

  end

  context 'Partnerships' do
    it 'can create partnership' do
      @coach.authenticated('testaschi', 'testaschi') {
        @coach.partnerships.find('testaschi','guschti').try(:destroy)
        @coach.users.find('testaschi').try(:destroy)
      }

      @coach.authenticated('guschti', 'guschti') { @coach.users.find('guschti').try(:destroy) }

      testaschi = @coach.users.create('testaschi', password: 'testaschi', email: 'testaschi@testaschi.testaschi', realname: 'testaschi Hunziker', publicvisible: 2)
      guschti = @coach.users.create('guschti', password: 'guschti', email: 'guschti@guschti.guschti', realname: 'Guschti Kyburz', publicvisible: 2)

      @coach.authenticated('testaschi', 'testaschi') do
        @ps = @coach.partnerships.create(testaschi.username, guschti.username, publicvisible: 2)

        expect(@coach.partnerships.exists?('testaschi', 'guschti')).to be_truthy
        expect(@ps.user1.username).to eq('testaschi')
        expect(@ps.user2.username).to eq('guschti')
        expect(@ps.confirmed_by_user1).to be(true)
        expect(@ps.confirmed_by_user2).to be(false)
        expect(@ps.user1.partnerships.first.user1.username).to eq('testaschi')

        testaschi.fetch
        guschti.fetch

        expect(testaschi.partnerships.size).to be > 0
        expect(guschti.partnerships.size).to be > 0

        expect(testaschi.pending_partnerships.size).to be 0
        expect(guschti.pending_partnerships.size).to be 1
      end

      @coach.authenticated('guschti', 'guschti') do
        guschti.confirm_partnership(@ps)

        expect(@ps.fetch.confirmed_by_user2).to be(true)
      end

    end
  end

end
