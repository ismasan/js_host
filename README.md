# Asset host for versioned Javascript APIs
After an idea from mloughran

## Dependencies
active_record --version 3.0.0.beta3
sinatra
closure-compiler

## Installation
Create config/database.yml and create database

    rake db:migrate
    rake db:populate
    
Run

    rackup -p 3000
    
See JsHost::AssetsHost for routes.