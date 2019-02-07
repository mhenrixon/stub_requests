# frozen_string_literal: true

#
# 1. Require core classes
#
require "forwardable"
require "singleton"

#
# 2. Require from gems
#
require "addressable/uri"
require "jaro_winkler"
require "concurrent/array"
require "concurrent/map"
require "docile"
require "public_suffix"
require "webmock"
require "webmock/api"
require "webmock/stub_registry"
require "webmock/request_stub"

#
# 3. Require shared functionality
#
require "stub_requests/core_ext"
require "stub_requests/exceptions"
require "stub_requests/utils/fuzzy"
require "stub_requests/concerns/argument_validation"
require "stub_requests/concerns/property"
require "stub_requests/concerns/property/validator"
require "stub_requests/concerns/register_verb"
require "stub_requests/uri"
require "stub_requests/uri/scheme"
require "stub_requests/uri/suffix"
require "stub_requests/uri/validator"
require "stub_requests/uri/builder"
require "stub_requests/configuration"

#
# 4. Require core functionality
#
require "stub_requests/callback"
require "stub_requests/callback_registry"
require "stub_requests/dsl"
require "stub_requests/dsl/method_definition"
require "stub_requests/dsl/define_method"
require "stub_requests/endpoint"
require "stub_requests/endpoint_registry"
require "stub_requests/request_stub"
require "stub_requests/service"
require "stub_requests/service_registry"
require "stub_requests/stub_registry"
require "stub_requests/webmock/builder"
require "stub_requests/webmock/stub_registry_extension"

#
# 5. Require public API
#
require "stub_requests/api"
require "stub_requests/version"
require "stub_requests/stub_requests"
