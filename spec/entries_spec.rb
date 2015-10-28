require 'spec_helper'

RSpec.describe 'CoachAPI', type: :model do

  before(:each) do
    @coach = Coach::Client.new
    @user = @coach.users.find('trackingtest')
  end

  after(:each) do
  end

  context 'Entries' do
    it 'should find entries of user' do
      entries = @coach.entries.all('trackingtest', 'cycling')
      expect(entries.count).to be > 0
    end

    it 'should have reference to subscription' do
      entry = @coach.entries.all('trackingtest', 'cycling').first.fetch

      expect { entry.subscription }.to_not raise_error
    end

    it 'should find entries through subscription model' do
      subscriptions = @user.subscriptions

      entries = subscriptions.map(&:entries).flatten

      expect(entries.count).to be > 0
    end

    it 'should throw error when creating entries unauthenticateds' do
      expect { @coach.entries.create('trackingtest','trackingtest', publicvisible: 2) }.to raise_error
    end

    it 'should crate new entry when authenticated' do
      @coach.authenticated('trackingtest', 'trackingtest') do
        created = @coach.entries.create('trackingtest', :cycling, publicvisible: 2)
        expect(created).to be_truthy
      end
    end
  end

end
