module V1
  class Organizations
    include Praxis::Controller

    implements V1::ApiResources::Organizations

    def create
      organization = Organization.create(request.payload.dump)
      CreatedWithBody.new(body: V1::MediaTypes::Organization.render(ActiveRecordProxy.new(organization)))
    end

    def index
      response.headers['Content-Type'] = 'application/json'
      response.body = Organization.all.map do |organization|
        V1::MediaTypes::Organization.render(ActiveRecordProxy.new(organization))
      end
      response
    end

    def update(id:)
      organization = Organization.find id
      organization.assign_attributes request.payload.dump
      organization.save!
      response.headers['Content-Type'] = 'application/json'
      response.body = V1::MediaTypes::Organization.render(ActiveRecordProxy.new(organization))
      response
    end

    def destroy(id:)
      Organization.find(id).destroy
      Praxis::Responses::NoContent.new
    end
  end
end
