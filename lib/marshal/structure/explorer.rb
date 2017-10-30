class Marshal::Structure
  # Adds a class method for exploring the resulting structure array.
  class << self
    def yield_and_recursively_traverse_structure_array(struc_arr, depth=0, &block)
      raise "Expecting a block!" unless block_given?
      el_type, el_id = struc_arr[0], struc_arr[1]

      yield depth, el_type, el_id, *struc_arr[2..-1]

      struc_arr[2..-1].each do |el|
        next unless el.is_a?(Array)
        yield_and_recursively_traverse_structure_array(el, depth, &block)
      end
    end
  end
end
