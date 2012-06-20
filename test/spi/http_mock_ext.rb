require "active_resource/http_mock"
# hack the active resource response to be compliant with Net::HTTPResponse
ActiveResource::Response.class_eval do
  alias_method :header, :headers
end