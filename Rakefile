%w[rubygems rake rake/clean fileutils].each { |f| require f }

Dir['lib/tasks/**/*.rake'].each { |t| load t }

namespace :db do
  
  desc 'load environment'
  task :environment do
    require 'js_host'
    include JsHost::Models
  end
  
  desc "Migrate the database"
  task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
  
  desc "Create test schema"
  task :create => :environment do
    ActiveRecord::Base.connection
  end
  
  desc 'Clear DB'
  task :clear => :environment do
    count = Project.count
    Project.destroy_all
    puts "#{count} projects deleted"
  end
  
  desc 'Populate DB'
  task :populate => :environment do
    project = Project.create!(:name => 'Demo')
    
    puts "Project #{project.slug}"
    
    ['0.0.1', '0.2.0', '1.2.3'].each do |v|
      major, minor, patch = v.split('.')
      f = project.versions.create!(
        :major => major, 
        :minor => minor, 
        :patch => patch,
        :hosted_file => HostedFile.new(:name => 'Test file', :body => File.read("./db/test_files/test-#{v}.js"))
      )
      puts "#{project.to_param}/#{f.to_param}/#{f.hosted_file.to_param}.js"
    end
    
  end
end
