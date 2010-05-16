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
      belongs_to :account
      
      scope :abc, order('updated_at DESC')
      
      def latest_version
        versions.abc.first
      end
    end
    
    class Version < ActiveRecord::Base
      belongs_to :project
      has_one :hosted_file, :dependent => :destroy
      
      scope :abc, order("major DESC, minor DESC, patch DESC")
            
      def self.find_by_version_string(version_string)
        major, minor, patch = version_string.split('.')
        where(:major => major, :minor => minor, :patch => patch).first
      end
      
      def etag
        Digest::MD5.hexdigest(version_string + hosted_file.body)
      end
      
      def version_string
        [major, minor, patch].join('.')
      end
      
      def version_string=(str)
        self.major, self.minor, self.patch = str.split('.')
      end
      
      def to_param
        version_string
      end

      def self.resolve_latest(major, minor = nil, patch = nil)
        r = where(:major => major)
        r = r.where(:minor => minor) if minor
        r = r.where(:patch => patch) if patch
        r.abc.includes(:hosted_file).first
      end
      
      def self.resolve_latest!(*args)
        resolve_latest(*args) or raise Sinatra::NotFound
      end

    end
    
    class HostedFile < ActiveRecord::Base
      include Sluggable
      
      belongs_to :version
    end

    class Token < ActiveRecord::Base
      belongs_to :account

      before_validation :generate_key_and_secret

      private

      def generate_key_and_secret
        self.key = ActiveSupport::SecureRandom.hex(20)
        self.secret = ActiveSupport::SecureRandom.hex(20)
      end
    end

    class Account < ActiveRecord::Base
      
      class VersionExists < RuntimeError;end
      
      has_many :projects, :dependent => :destroy
      has_many :tokens

      after_create :generate_token
      
      def key
        tokens.last.key
      end
      
      def secret
        tokens.last.secret
      end
      
      def create_or_update_project!(manifest, file)
        manifest_json = JSON.parse(manifest)

        transaction do
          project = projects.find_or_create_by_name(manifest_json['project'])
          version = project.versions.find_by_version_string(manifest_json['version'])
          
          raise 'Version already exists' if version
          
          project.versions.create!(
            :version_string => manifest_json['version'],
            :manifest => manifest,
            :hosted_file => HostedFile.new(
              :name => manifest['file'],
              :body => file
            )
          )
        end
      end

      private

      def generate_token
        self.tokens.create
      end
    end



  end
  
end