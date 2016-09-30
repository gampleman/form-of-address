require 'spec_helper'

describe V1::ApiResources::Organizations do
  before(:each) do
    use_api_version('1.0')
  end

  describe "POST /api/organizations (create)" do
    let!(:organization_count) { Organization.count }
    let!(:person_count) { Person.count }
    before(:each) do
      post "/api/organizations", params.to_json
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
        expect(json_response.slice(:name, :email, :phone, :address)).to eq({
          name: 'Test org1',
          email: 'org1@org1.com',
          phone: '0785 435 2234',
          address: 'Livingston 232, Arkansas'
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
        expect(json_response[:people]).to eq([
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
