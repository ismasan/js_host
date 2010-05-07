module JsHost
  
  module Models
    
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
      has_many :hosted_files, :dependent => :destroy
    end

    class HostedFile < ActiveRecord::Base
      belongs_to :project
      has_many :versions, :dependent => :destroy

      # name, url, etc
    end

    class Version < ActiveRecord::Base

      belongs_to :hosted_file

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