require 'rails_helper'

RSpec.describe Person, type: :model do
  let(:person) { Person.create! name: 'Rein' }
  let(:some_number) { ENV['SOME_NUMBER'].to_i }

  it 'has all the peoples' do
    some_number.times do
      expect(Person.all).to eq [person]
    end
  end

  context 'with variable peoples to create' do
    it 'creates some more peoples' do
      some_number.times do |i|
        Person.create! name: "Person #{i}"
      end

      expect(Person.count).to eq some_number
    end
  end
end
