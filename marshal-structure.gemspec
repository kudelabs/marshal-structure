# coding: utf-8
root_dir = File.expand_path(File.dirname(__FILE__))
lib = File.expand_path('../lib', __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'marshal/structure/version'

Gem::Specification.new do |spec|
  spec.name          = "marshal-structure"
  spec.version       = Marshal::Structure::VERSION
  spec.authors       = ["Jevgenij Solovjov"]
  spec.email         = ["jevgenij@kudelabs.com"]
  spec.require_paths = ["lib"]
end
