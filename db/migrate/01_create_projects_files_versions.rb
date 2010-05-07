class CreateProjectsFilesVersions < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name
      t.string :slug
      t.timestamps
    end
    
    create_table :versions do |t|
      t.references :project
      t.integer :major, :default => 0
      t.integer :minor, :default => 0
      t.integer :patch, :default => 0
      t.text :manifest
      t.timestamps
    end
    
    create_table :hosted_files do |t|
      t.references :version
      t.string :name
      t.string :slug
      t.string :content_type
      t.text :body
      t.timestamps
    end
    
    add_index :projects, :slug
    add_index :hosted_files, :slug
    add_index :hosted_files, :version_id
    add_index :versions, :project_id
    
    add_index :versions, [:major, :minor, :patch]
    add_index :versions, [:major, :minor]
    
    add_index :versions, :major
    add_index :versions, :minor
    add_index :versions, :patch
  end

  def self.down
    drop_table :projects
    drop_table :hosted_files
    drop_table :versions
  end
end