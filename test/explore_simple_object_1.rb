require 'pp'
require 'marshal/structure'
require 'pry-nav'

class SimpleFixtureNoIvars
  def initialize
    # well, do nothing here!
  end

  def meth1
    puts "I am meth1!"
  end
end

class SimpleFixtureIntIvar
  def initialize
    @int_ivar1 = 31
    @int_ivar2 = 12
    @float_ivar1 = 2.0
    @float_ivar2 = 3.0
  end
end

class SimpleFixtureStringIvar
  def initialize
    @str_ivar1 = "String ivar 1"
    @str_ivar2 = "String ivar 2"
  end
end

class SimpleFixtureEncStringIvar
  def initialize
    @str_ivar = "你好！"
  end
end

class SimpleFixtureArrIvar
  def initialize
    @arr_ivar = [1, 2, 3]
  end
end

class SimpleFixtureHashIvar
  def initialize
    @hash_ivar = {:a => 12, :b => 13, :c => 14}
  end
end

class SimpleFixtureWithIvarsArrayHash
  attr_reader :int_ivar, :string_ivar, :arr_ivar, :hash_ivar

  def initialize
    @int_ivar = 31
    @string_ivar = "String argument"
    @arr_ivar = [1, 2, 3]
    @hash_ivar = {:a => 12, :b => 13, :c => 14}
  end
end

class SimpleFixtureWithOtherObjIvar
  def initialize
    @obj_ivar1 = SimpleFixtureNoIvars.new
  end
end

class SimpleFixtureWithArrayLinkedIvar
  def initialize
    @obj_ivar = SimpleFixtureNoIvars.new
    @arr_ivar = [1, 2, 3]
    @arr_ivar << @obj_ivar
  end
end

CustomStruct = Struct.new(:field1, :field2)
class SimpleFixtureWithStructIvar
  def initialize
    @struct_ivar = CustomStruct.new(1, "value 1")
  end
end

strucs = {}
%w(SimpleFixtureNoIvars SimpleFixtureIntIvar SimpleFixtureStringIvar SimpleFixtureEncStringIvar
  SimpleFixtureArrIvar SimpleFixtureHashIvar SimpleFixtureWithIvarsArrayHash SimpleFixtureWithOtherObjIvar
  SimpleFixtureWithArrayLinkedIvar SimpleFixtureWithStructIvar).each do |klass_name|

  klass = eval(klass_name)
  obj = klass.new

  ms = Marshal::Structure.new(Marshal.dump(obj))
  struc = ms.parse_to_structure!
  strucs[klass_name.to_sym] = struc
end

binding.pry

# obj1 = SimpleFixtureWithIvarsArrayHash.new(31, "String argument", [1, 2, 3], {:a => 12, :b => 13, :c => 14})
#
# puts "Creating Marshal::Structure..."
# ms1 = Marshal::Structure.new(Marshal.dump(obj1))
# puts "Parsing to structure..."
# struc1 = ms1.parse_to_structure!
