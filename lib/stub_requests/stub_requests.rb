# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  # extends "self"
  # @!parse extend self
  extend self

  # includes "UriFor" and extends "UriFor"
  # using the API.included callback
  # @!parse include UriFor
  # @!parse extend UriFor

  # includes "API" and extends "API"
  # using the API.included callback
  # @!parse include API
  # @!parse extend API
  include API

  #
  # @!attribute [rw] logger
  #   @return [Logger] the logger to use in the gem
  attr_accessor :logger

  #
  # Allows the gem to be configured
  #
  #
  # @return [Configuration] <description>
  #
  # @yieldparam [Configuration] config <description>
  # @yieldreturn [<type>] <describe what yield should return>
  def configure
    yield(config) if block_given?
    config
  end

  #
  # Contains gem configuration
  #
  #
  # @return [Configuration]
  #
  def config
    @config ||= Configuration.new
  end

  #
  # The current version of the gem
  #
  #
  # @return [String] version string, `"1.0.0"`
  #
  def version
    VERSION
  end
end
