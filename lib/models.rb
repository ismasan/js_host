module JsHost
  
  module Models
    
    module Sluggable
      
      def self.included(base)
        base.before_save :sluggify
        base.validates_presence_of :name
        base.extend ClassMethods
      end
      
      def sluggify
        write_attribute :slug, self.name.parameterize
      end
      
      def to_param
        slug
      end
      
      module ClassMethods
        
        def find_by_slug!(slug)
          find_by_slug(slug) or raise Sinatra::NotFound.new("No #{self.name} with slug '#{slug}'")
        end
      end
    end
    
    class VersionNotFound < Sinatra::NotFound
      def initialize(conditions)
        @conditions = conditions
        super
      end

      def message
        "No file hosted with version #{@conditions.inspect}"
      end
    end
    
    class Project < ActiveRecord::Base
      include Sluggable
      
      has_many :versions, :dependent => :destroy
      
      def latest_version
        versions.desc.first
      end
      
    end
    
    class Version < ActiveRecord::Base

      belongs_to :project
      has_one :hosted_file, :dependent => :destroy

      scope :desc, order("major DESC, minor DESC, patch DESC")
      scope :asc, order("major ASC, minor ASC, patch ASC")
      
      def etag
        Digest::MD5.hexdigest(version_string + hosted_file.body)
      end
      
      def version_string
        [major, minor, patch].join('.')
      end
      
      def to_param
        version_string
      end

      def self.resolve_latest(major, minor = nil, patch = nil)
        r = where(:major => major)
        r = r.where(:minor => minor) if minor
        r = r.where(:patch => patch) if patch

        r.desc.includes(:hosted_file).first
      end
      
      def self.resolve_latest!(*args)
        resolve_latest(*args) or raise VersionNotFound.new({:major => major, :minor => minor, :patch => patch})
      end

    end
    
    class HostedFile < ActiveRecord::Base
      include Sluggable
      
      belongs_to :version
    end

  end
  
end