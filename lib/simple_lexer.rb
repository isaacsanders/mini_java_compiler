class SimpleLexer
  def run(input)
    input.split(/(\d+|\+|\-)/).reduce([]) do |tokens, pretoken|
      case pretoken
      when /\d+/
        tokens << pretoken
      when "+"
        tokens << "plus"
      when "-"
        tokens << "minus"
      when ''
        tokens
      end
    end
  end
end
