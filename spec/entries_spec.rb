require 'spec_helper'

RSpec.describe 'CoachAPI', type: :model do

  before(:each) do
    @coach = Coach::Client.new
  end

  after(:each) do
  end

  context 'Entries' do
    it 'should find entries of user' do
      entries = @coach.entries.all('trackingtest', 'cycling')
      expect(entries.count).to be > 0
    end
  end

end
