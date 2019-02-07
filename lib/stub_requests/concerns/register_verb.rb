# frozen_string_literal: true

module StubRequests
  module Concerns
    #
    # Module RegisterVerb provides <description>
    # @since 0.1.10
    #
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    #
    module RegisterVerb
      #
      # Convenience wrapper for register
      #
      #
      # @example **Register a get endpoint**
      # .  get("documents/:id", as: :documents_show)
      #
      # @param [String] path the path to the endpoint
      # @param [Symbol] as the id of the endpoint
      #
      # @return [Endpoint] the registered endpoint
      #
      def any(path, as:) # rubocop:disable Naming/UncommunicativeMethodParamName
        register(as, __method__, path)
      end

      #
      # Convenience wrapper for register
      #
      #
      # @example **Register a get endpoint**
      # .  get("documents/:id", as: :documents_show)
      #
      # @param [String] path the path to the endpoint
      # @param [Symbol] as the id of the endpoint
      #
      # @return [Endpoint] the registered endpoint
      #
      def get(path, as:) # rubocop:disable Naming/UncommunicativeMethodParamName
        register(as, __method__, path)
      end

      #
      # Register a :post endpoint
      #
      #
      # @example **Register a post endpoint**
      # .  post("documents", as: :documents_create)
      #
      # @param [String] path the path to the endpoint
      # @param [Symbol] as the id of the endpoint
      #
      # @return [Endpoint] the registered endpoint
      #
      def post(path, as:) # rubocop:disable Naming/UncommunicativeMethodParamName
        register(as, __method__, path)
      end

      #
      # Register a :patch endpoint
      #
      #
      # @example **Register a patch endpoint**
      # .  patch("documents/:id", as: :documents_update)
      #
      # @param [String] path the path to the endpoint
      # @param [Symbol] as the id of the endpoint
      #
      # @return [Endpoint] the registered endpoint
      #
      def patch(path, as:) # rubocop:disable Naming/UncommunicativeMethodParamName
        register(as, __method__, path)
      end

      #
      # Register a :put endpoint
      #
      #
      # @example **Register a put endpoint**
      # .  put("documents/:id", as: :documents_update)
      #
      # @param [String] path the path to the endpoint
      # @param [Symbol] as the id of the endpoint
      #
      # @return [Endpoint] the registered endpoint
      #
      def put(path, as:) # rubocop:disable Naming/UncommunicativeMethodParamName
        register(as, __method__, path)
      end

      #
      # Register a :delete endpoint
      #
      #
      # @example **Register a delete endpoint**
      # .  delete("documents/:id", as: :documents_destroy)
      #
      # @param [String] path the path to the endpoint
      # @param [Symbol] as the id of the endpoint
      #
      # @return [Endpoint] the registered endpoint
      #
      def delete(path, as:) # rubocop:disable Naming/UncommunicativeMethodParamName
        register(as, __method__, path)
      end
    end
  end
end
