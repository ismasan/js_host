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
          find_by_slug(slug) or raise ActiveRecord::RecordNotFound.new("No #{self.name} with slug '#{slug}'")
        end
      end
    end
    
    class VersionNotFound < StandardError
      def initialize(conditions)
        @conditions = conditions
        super
      end

      def message
        "No file hosted with version #{@conditions.inspect}"
      end
    end
    
    class Project < ActiveRecord::Base
      # belongs_to :account
      has_many :versions, :dependent => :destroy
    end

    class HostedFile < ActiveRecord::Base
      belongs_to :version
    end

    class Version < ActiveRecord::Base

      belongs_to :project
      has_one :hosted_file, :dependent => :destroy

      scope :sorted_by_version, order("major DESC, minor DESC, patch DESC")

      def version_string
        [major, minor, patch].join('.')
      end

      def self.resolve_latest(major, minor = nil, patch = nil)
        r = where(:major => major)
        r = r.where(:minor => minor) if minor
        r = r.where(:patch => patch) if patch

        r.sorted_by_version.first or raise VersionNotFound.new({:major => major, :minor => minor, :patch => patch})
      end

    end

  end
  
end