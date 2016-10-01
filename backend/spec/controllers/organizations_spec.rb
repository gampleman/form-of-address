require 'spec_helper'

describe V1::ApiResources::Organizations do
  before(:each) do
    use_api_version('1.0')
  end

  describe "GET /organizations (index)" do
    let(:org1) do
      Organization.create({
        name: 'Test org1',
        phone: '024343',
        people: [{
          name: 'Martin'
        }]
      })
    end
    let(:org2) do
      Organization.create({
        name: 'Test org2',
        phone: '4345543'
      })
    end

    before(:each) do
      get "/organizations"
      Organization.where('id NOT IN (?)', [org1.id, org2.id]).delete_all
    end

    it 'should return OK' do
      expect(response.status).to eq(200)
    end

    it 'should include both orgs' do
      expect(json_response.length).to eq(2)
    end

    it 'should have the available attributes' do
      expect(json_response[1].slice("name", "phone")).to eq({
        "name" => 'Test org2',
        "phone" => '4345543'
      })
    end

    it 'should include people attached to the orgs' do
      expect(json_response[0]["people"].length).to eq(1)
    end
  end

  describe "POST /organizations (create)" do
    let!(:organization_count) { Organization.count }
    let!(:person_count) { Person.count }
    before(:each) do
      post "/organizations", params.to_json
    end

    context "valid with no people" do
      let(:params) do
        {
          name: 'Test org1',
          email: 'org1@org1.com',
          phone: '0785 435 2234',
          address: 'Livingston 232, Arkansas',
          people: []
        }
      end

      it "has the correct response code" do
        expect(response.status).to eq(201)
      end

      it "returns the correct response" do
        expect(json_response.slice("name", "email", "phone", "address")).to eq({
          "name" => 'Test org1',
          "email" => 'org1@org1.com',
          "phone" => '0785 435 2234',
          "address" => 'Livingston 232, Arkansas'
        })
      end

      it "creates an organization" do
        expect(Organization.count).to eq(organization_count + 1)
      end
    end

    context "valid with people" do
      let(:params) do
        {
          name: 'Test org1',
          email: 'org1@org1.com',
          phone: '0785 435 2234',
          address: 'Livingston 232, Arkansas',
          people: [
            {
              name: 'John Doe',
              email: 'john@org1.com',
              phone: '34453645354'
            },
            {
              name: 'Audrey Burn',
              email: 'audrey@org1.com',
              phone: '34453645357'
            }
          ]
        }
      end

      it "has the correct response code" do
        expect(response.status).to eq(201)
      end

      it "returns the correct response" do
        expect(json_response["people"].map{|p| p.slice("name", "email", "phone")}).to eq([
          {
            "name" => 'John Doe',
            "email" => 'john@org1.com',
            "phone" => '34453645354'
          },
          {
            "name" => 'Audrey Burn',
            "email" => 'audrey@org1.com',
            "phone" => '34453645357'
          }
        ])
      end

      it "creates an organization" do
        expect(Organization.count).to eq(organization_count + 1)
      end

      it "creates some people" do
        expect(Person.count).to eq(person_count + 2)
      end
    end
  end
end
