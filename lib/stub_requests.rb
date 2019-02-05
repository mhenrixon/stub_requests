# frozen_string_literal: true

require "forwardable"
require "singleton"

require "concurrent/array"
require "concurrent/map"
require "docile"
require "webmock"
require "webmock/api"
require "webmock/stub_registry"
require "webmock/request_stub"

require "stub_requests/version"

require "stub_requests/argument_validation"
require "stub_requests/core_ext"
require "stub_requests/exceptions"
require "stub_requests/hash_util"
require "stub_requests/property"
require "stub_requests/property/validator"
require "stub_requests/uri"
require "stub_requests/uri/scheme"
require "stub_requests/uri/suffix"
require "stub_requests/uri/validator"
require "stub_requests/uri/builder"
require "stub_requests/configuration"

require "stub_requests/callback"
require "stub_requests/callback_registry"

require "stub_requests/metrics"
require "stub_requests/metrics/endpoint"
require "stub_requests/metrics/request"
require "stub_requests/metrics/registry"

require "stub_requests/endpoints"
require "stub_requests/endpoint"
require "stub_requests/service"
require "stub_requests/service_registry"

require "stub_requests/webmock/builder"
require "stub_requests/webmock/stub_registry_extension"

require "stub_requests/api"
require "stub_requests/stub_requests"
require "stub_requests/dsl"
