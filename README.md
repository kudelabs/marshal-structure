= marshal-structure

home :: https://github.com/kudelabs/marshal-structure
rdoc :: http://docs.seattlerb.org/marshal-structure
bugs :: https://github.com/drbrain/marshal-structure/issues

== Description

This project is based on Eric Hodel's https://github.com/drbrain/marshal-structure/,
and is the cloned and updated version of it tailored for our immediate needs.

Tools to inspect and analyze Ruby's Marshal serialization format.  Supports
the Marshal 4.8 format which is emitted by ruby 1.8 through 2.x.

== Examples

To dump the structure of a Marshal stream:

  ruby -rpp -rmarshal/structure \
    -e 'pp Marshal::Structure.load Marshal.dump "hello"'

Fancier usage:

  require 'pp'
  require 'marshal/structure'

  ms = Marshal::Structure.new Marshal.dump %w[hello world]
  structure_array = ms.parse_to_structure!

  # print the stream structure Array
  pp structure_array

  # recursively traverse the structure Array and print info about :string entries
  Marshal::Structure.yield_and_recursively_traverse_structure_array(structure_array) do |depth, el_type, el_id, *args|
    if el_type == :string
      puts "I am :#{el_type} at depth level ##{depth} containing '#{args[0]}'"
    end
  end

  # compose hash of Symbols defined in the dump, by their symlink id encountered in the dump
  Marshal::Structure.get_symbols_hash_by_id(structure_array)

  # count distinct instances of user-defined objects in the stream (:object record)
  Marshal::Structure.get_object_counts(structure_array)

== Scripts

You can look at what structure certain simple fixtures have in the dump file:

$ ruby -Ilib test/explore_simple_objects.rb

- you will end up in 'pry' session where you can explore 'strucs' hash, and also
the script will produce explore_simple_structures.dump file with dump of hash of
all defined objects there.

You can count objects in a dump using bin/count_entries:

$ ruby -Ilib bin/count_entries explore_simple_structures.dump

== Installation
== Developers

Add gem to the Gemfile:

gem 'marshal-structure', git: "git@github.com:kudelabs/marshal-structure.git", branch: "develop"

and run "bundle install".


== License

(The MIT License)

Copyright (c) Eric Hodel

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
