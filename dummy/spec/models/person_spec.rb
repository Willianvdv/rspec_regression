require 'rails_helper'

RSpec.describe Person, type: :model do
  let(:person) { Person.create! name: 'Rein' }

  it 'has all the peoples' do
    expect(Person.all).to eq [person]
  end

  context 'with variable peoples to create' do
    let(:amount_of_peoples_to_create) { ENV['AMOUNT_OF_PEOPLES_TO_CREATE'].to_i }

    it 'creates some more peoples' do
      amount_of_peoples_to_create.times do |i|
        Person.create! name: "Person #{i}"
      end

      expect(Person.count).to eq amount_of_peoples_to_create
    end
  end
end
