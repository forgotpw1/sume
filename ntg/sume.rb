#!/usr/bin/env ruby
require 'yard'
require 'json'

# Replace YARD's default with our own
template_path = File.expand_path(File.dirname(__FILE__) + "/templates")
YARD::Templates::Engine.template_paths = [template_path]

rails_files = Dir["rails/act*/lib/**/*.rb"]
YARD::Registry.load(rails_files)

module Sume
  def self.write(object)
    File.open(path(object) + ".html", "w+") do |f|
      f.write(object.format(:format => :html))
    end
  end

  def self.path(object)
    object.path.gsub(/::|#|\./, '/')
  end
end


index = []
paths = {}
custom_weights = Hash.new(0)
custom_weights["ActiveRecord::Associations::ClassMethods#has_many"] = 2
custom_weights["ActiveRecord::Associations::ClassMethods#has_one"] = 2
custom_weights["ActiveRecord::Associations::ClassMethods#belongs_to"] = 2
custom_weights["ActiveRecord::Associations::ClassMethods#has_and_belongs_to_many"] = 2
custom_weights["ActiveRecord::Calculations#sum"] = 2
custom_weights["ActiveRecord::Calculations#calculate"] = 2
custom_weights["ActiveRecord::Calculations#maximum"] = 2
custom_weights["ActiveRecord::Calculations#minimum"] = 2
custom_weights["ActiveRecord::Calculations#pluck"] = 2
custom_weights["ActiveRecord::Calculations#average"] = 2
custom_weights["ActiveRecord::Base.create"] = 2
custom_weights["ActiveRecord::FinderMethods#find"] = 2
custom_weights["ActiveRecord::FinderMethods#all"] = 2
custom_weights["ActiveRecord::FinderMethods#first"] = 2
custom_weights["ActiveRecord::FinderMethods#first!"] = 1.9
custom_weights["ActiveRecord::FinderMethods#last"] = 2
custom_weights["ActiveRecord::FinderMethods#last!"] = 2
custom_weights["ActiveRecord::FinderMethods#exists?"] = 2
custom_weights["ActiveRecord::ConnectionAdapters::SchemaStatements#create_table"] = 2
custom_weights["ActiveRecord::ConnectionAdapters::SchemaStatements#add_column"] = 2
custom_weights["ActiveRecord::ConnectionAdapters::SchemaStatements#remove_column"] = 2
custom_weights["ActiveRecord::ConnectionAdapters::SchemaStatements#change_column"] = 2
custom_weights["ActiveRecord::ConnectionAdapters::SchemaStatements#change_column_default"] = 2
custom_weights["ActiveRecord::ConnectionAdapters::SchemaStatements#drop_table"] = 2
custom_weights["ActiveRecord::Persistence#update_attributes"] = 2
custom_weights["ActiveRecord::Persistence#update_attributes!"] = 1.9
custom_weights["ActiveRecord::Persistence#update_attribute"] = 1.9
custom_weights["ActiveRecord::Persistence#persisted?"] = 2
custom_weights["ActiveRecord::Persistence#new_record?"] = 2
custom_weights["ActiveRecord::Persistence#save"] = 2
custom_weights["ActiveRecord::Persistence#save!"] = 2
custom_weights["ActiveRecord::Persistence#decrement!"] = 1.9
custom_weights["ActiveRecord::Persistence#increment"] = 2
custom_weights["ActiveRecord::Persistence#increment!"] = 1.9
custom_weights["ActiveRecord::Persistence#toggle"] = 2
custom_weights["ActiveRecord::Persistence#toggle!"] = 1.9
custom_weights["ActiveRecord::Persistence#destroy"] = 2
custom_weights["ActiveRecord::Relation#destroy_all"] = 2
custom_weights["ActiveRecord::Associations::CollectionAssociation#destroy_all"] = 2
custom_weights["ActiveRecord::NamedScope::ClassMethods#scope"] = 2
custom_weights["ActiveRecord::NamedScope::ClassMethods#scoped"] = 1.9
custom_weights["ActiveRecord::NamedScope::ClassMethods#unscoped"] = 1.9
custom_weights["ActiveRecord::Validations#valid?"] = 2

custom_weights["ActionDispatch::Routing::Mapper::Resources#resources"] = 2
custom_weights["ActionDispatch::Routing::Mapper::Scoping#namespace"] = 2
custom_weights["ActionDispatch::Routing::Mapper::Scoping#scope"] = 1.9
custom_weights["ActionDispatch::Routing::Mapper::Scoping#constraints"] = 2

custom_weights["ActionController::Redirecting#redirect_to"] = 2
custom_weights["ActionController::Redirecting#redirect_to"] = 2
custom_weights["ActionDispatch::Routing::Mapper::Scoping#controller"] = 2
custom_weights["ActionDispatch::Routing::Mapper::Scoping#defaults"] = 2
custom_weights["ActionDispatch::Routing::Mapper::HttpHelpers#get"] = 2
custom_weights["ActionDispatch::Routing::Mapper::HttpHelpers#post"] = 2
custom_weights["ActionDispatch::Routing::Mapper::HttpHelpers#put"] = 2
custom_weights["ActionDispatch::Routing::Mapper::HttpHelpers#delete"] = 2
custom_weights["ActionDispatch::Routing::Mapper::Resources#member"] = 2
custom_weights["ActionDispatch::Routing::Mapper::Resources#collection"] = 2


FileUtils.mkdir_p("doc")
Dir.chdir("doc") do
  classes = YARD::Registry.all(:class)
  modules = YARD::Registry.all(:module)
  methods = YARD::Registry.all(:method)

  (classes + modules).each do |object|
    FileUtils.mkdir_p(Sume.path(object))
    Sume.write(object)
    paths[object.path] = Sume.path(object) + ".html"
  end

  methods.each do |object|
    Sume.write(object)
    unless object.docstring.blank? || object.docstring.strip == ":doc"
      index << object.path
      paths[object.path] = Sume.path(object) + ".html"
      custom_weights[object.path] ||= object.visibility == :public ? 1 : 0
    end
  end
end

File.open("../sume_index.js", "w+") do |f|
  f.write %Q{
Sume.index = #{index.to_json}
Sume.paths = #{paths.to_json}
Sume.weights = #{custom_weights.to_json}
  }
end



