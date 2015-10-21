require 'spec_helper'

RSpec.describe 'CoachAPI', type: :model do

  context 'Users' do
    it 'returns list of all users' do
      expect { Coach::User.all }.to_not raise_error
    end

    it 'lists all users' do
      expect(Coach::User.all.count).to be > 5
    end

    it 'should find newuser1' do
      expect(Coach::User.find('newuser1')).to be_truthy
    end

    it 'can search for usernames' do
      results = Coach::User.all(search: 'newuser1')

      expect(results).to be_truthy
      expect(results.count).to be > 0
      #expect(results.map(&:fetch)).to include Coach::User.find('newuser1')
    end

    it 'should have accessible partnerships' do
      user = Coach::User.find('newuser1')
      expect { user.partnerships }.to_not raise_error
    end

    it 'should have accessible subscriptions' do
      user = Coach::User.find('newuser1')
      expect { user.subscriptions }.to_not raise_error
    end

    it 'should return partnerships with correct type' do
      user = Coach::User.find('newuser1')
      expect(user.partnerships.first).to be_a Coach::Partnership
    end

    it 'should return subscription with correct type' do
      user = Coach::User.find('newuser1')
      expect(user.subscriptions.first).to be_a Coach::Subscription
    end

    it 'should equal the user of its subscription' do
      user = Coach::User.find('newuser1')
      expect(user.subscriptions.first.user).to eq user
    end

    it 'should equal one user of its partnership' do
      user = Coach::User.find('newuser1')
      partnership = user.partnerships.first

      expect(partnership.users).to include user
    end

    it 'can delete user via model' do
      user = if Coach::User.exists?('housi')
               Coach::User.find('housi')
             else
               Coach::User.create('housi', password: 'housi', email: 'test@housi.ch', realname: 'housi', publicvisible: 2)
             end

      expect { Coach::User.authenticated('housi', 'housi') { user.destroy } }.to_not raise_error
      expect(Coach::User.exists?('housi')).to be_falsey
    end

    it 'can modify user via model' do
      Coach::User.authenticated('housi', 'housi') { Coach::User.find('housi').destroy } if Coach::User.exists?('housi')
      user = Coach::User.create('housi', password: 'housi', email: 'test@housi.ch', realname: 'housi', publicvisible: 2)

      expect(user.real_name).to eq('housi')

      expect {
        Coach::User.authenticated('housi', 'housi') do
          user.update realname: 'housinew'
        end
      }.to_not raise_error

      expect(user.real_name).to eq 'housinew'
    end

  end

end
