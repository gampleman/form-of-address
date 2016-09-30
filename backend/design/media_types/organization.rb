module V1
  module MediaTypes
    class Organization < Praxis::MediaType

      identifier 'application/json'

      attributes do
        attribute :id, Integer, description: 'The id of the resource'
        attribute :name, String, description: 'The name of the organization'
        attribute :email, String, description: 'An email address that represents this organization'
        attribute :phone, String, description: 'A phone number'
        attribute :address, String, description: 'An address'
        attribute :people, Attributor::Collection.of(V1::MediaTypes::Person), description: 'People bellonging to this organization'
      end

      view :default do
        schema.attributes.keys.each { |k| attribute k }
      end
    end
  end
end
