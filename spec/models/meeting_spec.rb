require 'rails_helper'

RSpec.describe Meeting, type: :model do
  describe 'associations' do
    it { should belong_to(:organization) }
    it { should belong_to(:creator).class_name('User') }
    it { should have_many(:tasks).dependent(:destroy) }
    it { should have_one_attached(:audio_file) }
  end

  describe 'enums' do
    it do
      should define_enum_for(:status)
        .with_values(scheduled: 0, completed: 1, cancelled: 2)
    end
  end
end
