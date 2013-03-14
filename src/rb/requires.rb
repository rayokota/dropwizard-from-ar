require 'rubygems'
require "bundler/setup"

require 'erb'
require "fileutils"
require 'yaml'

gem 'activesupport', ">=3.0.0"
require "active_support/all"

require File.expand_path(File.dirname(__FILE__) + "/ext/string")
require File.expand_path(File.dirname(__FILE__) + "/association_defn")
require File.expand_path(File.dirname(__FILE__) + "/field_defn")
require File.expand_path(File.dirname(__FILE__) + "/model_defn")
require File.expand_path(File.dirname(__FILE__) + "/database_defn")
require File.expand_path(File.dirname(__FILE__) + "/project_defn")
require File.expand_path(File.dirname(__FILE__) + "/schema_rb_parser")
require File.expand_path(File.dirname(__FILE__) + "/models_dir_processor")
require File.expand_path(File.dirname(__FILE__) + "/template_processor")
