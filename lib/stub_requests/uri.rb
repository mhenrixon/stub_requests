# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module URI organizes all gem logic regarding URI
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.2
  #
  module URI
    #
    # @return [Regexp] A pattern for matching route parameters
    ROUTE_PARAM = %r{/:(\w+)/?}.freeze

    #
    # Extracts route parameters from a string
    #
    # @param [String] string a regular string to scan for route parameters
    #
    # @return [Array<Symbol>] an array with all route parameter keys
    #
    def self.route_params(string)
      string.scan(ROUTE_PARAM).flatten.map(&:to_sym)
    end

    #
    # Safely joins two string without any extra ///
    #
    # @param [String] host the host of the URI
    # @param [String] path the path of the URI
    #
    # @return [String] the full URI
    #
    def self.safe_join(host, path)
      [host.chomp("/"), path.sub(%r{\A/}, "")].join("/")
    end
  end
end
