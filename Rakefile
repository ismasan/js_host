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
    project = Project.create!(:name => 'test', :slug => 'test')
    file = project.hosted_files.create!(:name => 'test file', :slug => 'test-file')
    
    v = []
    v << file.versions.create!(:body => File.read('./db/test_files/test-0.0.1.js'), :major => 0, :minor => 0, :patch => 1)
    v << file.versions.create!(:body => File.read('./db/test_files/test-0.2.0.js'), :major => 0, :minor => 2, :patch => 0)
    v << file.versions.create!(:body => File.read('./db/test_files/test-1.2.3.js'), :major => 1, :minor => 2, :patch => 3)
    
    puts "Project #{project.slug}"
    puts "File #{file.slug}"
    v.each do |version|
      puts "Version #{[version.major, version.minor, version.patch].join('.')}"
    end
    
  end
end
