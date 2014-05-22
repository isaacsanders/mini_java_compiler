module Intermediate
  class ContinueStatement < Statement
    def to_mips(stack_frame)
      ["j loop#{loop_stack.last}"]
    end

    def check_types(errors)
    end
  end
end
