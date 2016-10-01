module V1
  module ApiResources
    class Organizations
      include Praxis::ResourceDefinition

      media_type V1::MediaTypes::Organization
      version '1.0'

      action :index do
        routing do
          get ''
        end
        response :ok, media_type: Praxis::Collection.of(V1::MediaTypes::Organization)
      end

      action :create do
        routing do
          post ''
        end

        payload do
          attribute :name
          attribute :email
          attribute :phone
          attribute :address
          attribute :people
        end

        response :created_with_body, media_type: Praxis::Collection.of(V1::MediaTypes::Organization)
      end

      action :update do
        routing do
          patch '/:id'
        end

        params do
          attribute :id, Integer, required: true, min: 0
        end

        payload do
          attribute :name
          attribute :email
          attribute :phone
          attribute :address
          attribute :people
        end

        response :not_found
        response :ok
      end

      action :show do
        routing do
          get '/:id'
        end

        params do
          attribute :id, Integer, required: true, min: 0
        end

        response :not_found
        response :ok, media_type: V1::MediaTypes::Organization
      end

      action :delete do
        routing do
          delete '/:id'
        end

        params do
          attribute :id, Integer, required: true, min: 0
        end

        response :not_found
        response :ok
      end
    end
  end
end
