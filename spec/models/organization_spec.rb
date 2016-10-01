require 'spec_helper'

describe Organization do
  let(:organization) do
    Organization.new
  end
  let!(:people_count) do
    Person.count
  end
  describe '#people=' do
    it "creates new person records if the hashes don't contain ids" do
      organization.people = [{
        name: 'Test 1',
        phone: '24354365'
      }, {
        name: 'Test 2',
        phone: '3445354'
      }]

      expect(organization.people.length).to eq(2)
      expect(Person.count).to eq(people_count + 2)
    end
  end
end
