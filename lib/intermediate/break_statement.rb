module Intermediate
  class BreakStatement < Statement
    def to_mips(stack_frame)
      ["j exit#{loop_stack.last}"]
    end

    def check_types(errors)
    end
  end
end
