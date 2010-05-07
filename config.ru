require 'js_host'

app = Rack::URLMap.new(
  '/'             => JsHost::AssetHost,
  '/api'          => JsHost::Api
)
run app