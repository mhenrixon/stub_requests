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
    include Property

    property :record_metrics, type: [TrueClass, FalseClass], default: false
    #
    # @!attribute [rw] logger
    #   @return [Logger] any object that responds to the standard logger methods
    attr_accessor :logger
  end
end
