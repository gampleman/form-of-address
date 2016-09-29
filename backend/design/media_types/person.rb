module V1
  module MediaTypes
    class Person < Praxis::MediaType

      identifier 'application/json'

      attributes do
        attribute :name, String, description: 'The name of the person'
        attribute :email, String, description: 'An email address'
        attribute :phone, String, description: 'A phone number'
        attribute :address, String, description: 'A physical address'
      end

      view :default do
        schema.attributes.keys.each { |k| attribute k }
      end
    end
  end
end
