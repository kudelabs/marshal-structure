class Marshal::Structure
  # Adds a class method for exploring the resulting structure array.
  class << self
    def yield_and_recursively_traverse_structure_array(struc_arr, depth=0, &block)
      raise "Expecting a block!" unless block_given?
      el_type, el_id = struc_arr[0], struc_arr[1]

      yield depth, el_type, el_id, *struc_arr[2..-1]

      struc_arr[2..-1].each do |el|
        next unless el.is_a?(Array)
        yield_and_recursively_traverse_structure_array(el, depth+1, &block)
      end
    end

    def get_symbols_hash_by_id(struc_arr)
      result = {}
      yield_and_recursively_traverse_structure_array(struc_arr) do |depth, el_type, el_id, sym_name|
        if el_type == :symbol
          #puts "I am :#{el_type} at depth level ##{depth} containing #{args}"
          result[el_id] = sym_name.to_sym
        end
      end
      result
    end

    def get_nonprimitive_object_counts(struc_arr)
      sym_table = get_symbols_hash_by_id(struc_arr)

      result = {}
      yield_and_recursively_traverse_structure_array(struc_arr) do |depth, el_type, el_id, *args|
        if el_type == :object
          class_info = args[0]
          name_typ, name_symbol_id = class_info[0..1]
          raise "Unexpected Object name type ':#{name_typ}', only know how to handle :symbol or :symbol_link" unless name_typ == :symbol || name_typ == :symbol_link
          class_name = sym_table[name_symbol_id]

          result[class_name] = 0 if !result[class_name]
          result[class_name] += 1
        end
      end
      result
    end
  end
end
