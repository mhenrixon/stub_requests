# frozen_string_literal: true

require "singleton"
require "docile"
require "webmock"
require "webmock/api"
require "webmock/stub_registry"
require "webmock/request_stub"

require "stub_requests/version"

require "stub_requests/core_ext"
require "stub_requests/hash_util"
require "stub_requests/argument_validation"
require "stub_requests/endpoint"
require "stub_requests/endpoint_registry"
require "stub_requests/service"
require "stub_requests/service_registry"
require "stub_requests/metrics/registry"
require "stub_requests/uri/scheme"
require "stub_requests/uri/suffix"
require "stub_requests/uri/validator"
require "stub_requests/uri/builder"
require "stub_requests/webmock/stub_registry_extension"
require "stub_requests/webmock_builder"

require "stub_requests/api"

require "stub_requests/stub_requests"
