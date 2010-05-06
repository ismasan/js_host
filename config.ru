require 'js_host'

app = Rack::URLMap.new(
  '/'             => JsHost::AssetHost,
  '/accounts'     => JsHost::AccountsApi,
  '/projects'     => JsHost::ProjectsApi
)
run app