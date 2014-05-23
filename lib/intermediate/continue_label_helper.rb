module Intermediate
  class ContinueLabelHelper < Statement
    def to_mips(stack_frame)
      ["continue#{$loop_stack.last}:", "nop"]
    end

    def check_types(errors)
    end
  end
end
