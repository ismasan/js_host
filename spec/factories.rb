include JsHost::Models

Factory.define :account do |f|
  f.email 'demo@email.com'
  f.password 'password'
end

Factory.define :project do |f|
  f.name 'Demo'
end

Factory.define :hosted_file do |f|
  f.name 'Demo'
  f.content_type 'application/javascript'
  f.body %(
    // this is a comment
    function foo(bar){
      return 2 * bar;
    }
  )
end

Factory.define :version do |f|
  f.major 1
  f.minor 1
  f.patch 1
  f.manifest '{}'
end