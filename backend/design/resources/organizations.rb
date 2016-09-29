module V1
  module ApiResources
    class Organizations
      include Praxis::ResourceDefinition

      media_type V1::MediaTypes::Organization
      version '1.0'

      action_defaults do
        response :ok
      end

      action :index do
        routing do
          get ''
        end
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
      end

      action :show do
        routing do
          get '/:id'
        end

        params do
          attribute :id, Integer, required: true, min: 0
        end

        response :not_found
      end

      action :delete do
        routing do
          delete '/:id'
        end

        params do
          attribute :id, Integer, required: true, min: 0
        end

        response :not_found
      end
    end
  end
end
