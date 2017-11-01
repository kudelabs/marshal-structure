# Helper class for traversal and exploration of structure Array resulting from
# parse_to_structure! call on Marshal::Structure object.
#
# Typical usage example:
#
# TODO
#
class Marshal::Structure   #::Explorer
  class << self
    # def yield_and_recursively_traverse_structure_array(struc_arr, depth=0, &block)
    #   raise "Expecting a block!" unless block_given?
    #   el_type, el_id = struc_arr[0], struc_arr[1]
    #
    #   yield depth, el_type, el_id, *struc_arr[2..-1]
    #
    #   struc_arr[2..-1].each do |el|
    #     next unless el.is_a?(Array)
    #     yield_and_recursively_traverse_structure_array(el, depth+1, &block)
    #   end
    # end

    def yield_and_recursively_traverse_structure_array(struc_arr, &block)
      raise "Expecting a block!" unless block_given?

      # Setting initial values for iterative exploration of the nested array structure
      nested_subarray_stack, traverse_position_stack = [], []
      nested_subarray_stack.push(struc_arr)
      traverse_position_stack.push(0)

      while (depth=traverse_position_stack.size) > 0
        raise "Sanity check failed: mismatch between traverse_position_stack.size and nested_subarray_stack.size" unless traverse_position_stack.size == nested_subarray_stack.size

        curr_ary = nested_subarray_stack.last
        curr_pos = traverse_position_stack.last

        #puts "DEBUG: depth = #{depth}, curr_pos = #{curr_pos}, curr_ary.class = #{curr_ary.class}"
        #binding.pry unless curr_ary.is_a?(Array)
        #puts "DEBUG: curr_ary = #{curr_ary}"

        # if we're just starting with the Array, we should yield to block and let it do its thingie
        if curr_pos == 0
          el_type, el_id = curr_ary[0], curr_ary[1]

          yield(depth, el_type, el_id, curr_ary)

          if el_type.is_a?(Fixnum) || el_type == :instance_variables
            # useful info starts from position 1 - continue investigating in this iteration
          elsif el_type == :array || el_type == :hash || el_type == :struct
            # "custom" move on: let the cycle below investigate Array from entry 3
            traverse_position_stack[-1] = 2  # in
          else
            # "standard" move on: let the cycle below investigate Array from entry 2
            traverse_position_stack[-1] = 1
          end

        end

        # if we've already yielded and aren't at 0th position - let's look for nested Arrays
        next_nested_ary_pos = curr_ary[(curr_pos+1)..-1].find_index{|el| el.is_a?(Array)}
        if next_nested_ary_pos
          # we've got a nested array - update the positions:
          next_nested_ary_pos = (curr_pos + 1) + next_nested_ary_pos   # adjust result of find_index for the offset of the starting position

          traverse_position_stack[-1] = next_nested_ary_pos   # new position in current Array
          nested_subarray_stack.push(curr_ary[next_nested_ary_pos])   # the nested subarray
          traverse_position_stack.push(0)   # finally, the position in nested subarray - 0
          next
        else
          # we're done - let's take last entries off the stack Arrays
          traverse_position_stack.pop
          nested_subarray_stack.pop
          next
        end
      end
    end


    def get_symbols_hash_by_id(struc_arr)
      result = {}
      yield_and_recursively_traverse_structure_array(struc_arr) do |depth, el_type, el_id, curr_ary|
        sym_name = curr_ary[2]
        if el_type == :symbol
          #puts "I am :#{el_type} at depth level ##{depth} containing :#{sym_name}"
          result[el_id] = sym_name.to_sym
        end
      end
      result
    end

    def get_object_counts(struc_arr)
      sym_table = get_symbols_hash_by_id(struc_arr)
      result = {}

      yield_and_recursively_traverse_structure_array(struc_arr) do |depth, el_type, el_id, curr_ary|
        # # in properly formed marshalled data symbol definition clearly must precede its linked use

        next if el_type.is_a?(Fixnum)  # this is a list of instance variables in an object - don't count anything quite yet

        case el_type
        when :symbol, :float, :fixnum, :bignum, :string
          result[:primitives] = {} unless result[:primitives]
          result[:primitives][el_type] = 0 unless result[:primitives][el_type]
          result[:primitives][el_type] += 1
        when :array, :hash, :hash_default, :struct
          # primitives and fundamental data structures - simply count each of them
          result[:collections] = Hash.new(0) unless result[:collections]
          result[:collections][el_type] += 1
        when :symbol_link, :link
          result[:links] = {} unless result[:links]
          result[:links][el_type] = 0 unless result[:links][el_type]
          result[:links][el_type] += 1
        when :object
          class_info = curr_ary[2]
          name_typ, name_symbol_id = class_info[0..1]
          raise "Unexpected Object name type ':#{name_typ}', only know how to handle :symbol or :symbol_link" unless name_typ == :symbol || name_typ == :symbol_link
          class_name = sym_table[name_symbol_id]

          result[:custom_objects] = Hash.new(0) unless result[:custom_objects]
          result[:custom_objects][class_name] += 1
        when :user_class, :extended
          class_info = curr_ary[1]
          name_typ, name_symbol_id = class_info[0..1]
          raise "Unexpected Object name type ':#{name_typ}', only know how to handle :symbol or :symbol_link" unless name_typ == :symbol || name_typ == :symbol_link
          class_name = sym_table[name_symbol_id]

          result[:custom_objects] = Hash.new(0) unless result[:custom_objects]
          result[:custom_objects][class_name] += 1
        when :user_marshal, :user_defined
          class_info = curr_ary[2]
          name_typ, name_symbol_id = class_info[0..1]
          raise "Unexpected Object name type ':#{name_typ}', only know how to handle :symbol or :symbol_link" unless name_typ == :symbol || name_typ == :symbol_link
          class_name = sym_table[name_symbol_id]

          result[:custom_marshal_objects] = Hash.new(0) unless result[:custom_marshal_objects]
          result[:custom_marshal_objects][class_name] += 1
        when :instance_variables
          # ignore - this one normally references other objects
          next
        else
          result[:unsure_how_to_count] = {} unless result[:unsure_how_to_count]
          result[:unsure_how_to_count][el_type] = 0 unless result[:unsure_how_to_count][el_type]
          result[:unsure_how_to_count][el_type] += 1
        end
      end
      result
    end
  end
end
