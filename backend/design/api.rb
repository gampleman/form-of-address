# Use this file to define your response templates and traits.
#
# For example, to define a response template:
#   response_template :custom do |media_type:|
#     status 200
#     media_type media_type
#   end
Praxis::ApiDefinition.define do
  info do
    name 'Form of Address'
    endpoint 'http://localhost'
    consumes 'json'
  end

  response_template :created_with_body do |media_type:, location: nil|
    media_type media_type
    location location
    status 201
  end
end
