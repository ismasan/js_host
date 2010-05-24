require 'js_host'

app = Rack::URLMap.new(
  '/api'             => JsHost::Api,
  '/'          => JsHost::AssetHost
)
run app