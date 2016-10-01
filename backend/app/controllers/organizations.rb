module V1
  class Organizations
    include Praxis::Controller

    implements V1::ApiResources::Organizations

    def create
      organization = Organization.create(request.payload.dump)
      CreatedWithBody.new(body: V1::MediaTypes::Organization.render(ActiveRecordProxy.new(organization)))
    end
  end
end
