# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Class Configuration contains gem configuration
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.2
  #
  class Configuration
    # includes "Concerns::Property"
    # @!parse include Concerns::Property
    include Concerns::Property

    #
    # @!attribute [rw] record_stubs
    #   @return [Hash] record_stubs set to true to keep track of stubs
    property :record_stubs, type: [TrueClass, FalseClass], default: false
    #
    # @!attribute [rw] jaro_options
    #   @return [Hash] options to use for jaro winkler
    property :jaro_options, type: Hash, default: {
      weight: 0.1,
      threshold: 0.7,
      ignore_case: true,
    }
    #
    # @!attribute [rw] logger
    #   @return [Logger] any object that responds to the standard logger methods
    property :logger, type: Logger
  end
end
