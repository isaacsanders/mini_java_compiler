require 'minitest/autorun'
require_relative '../lib/simple_lexer'

class TestSimpleLexer < MiniTest::Test
  def setup
    @lexer = SimpleLexer.new
  end

  def test_outputs_single_digit
    assert_equal ["1"], @lexer.run("1")
  end

  def test_outputs_plus
    assert_equal ["plus"], @lexer.run("+")
  end

  def test_outputs_plus
    assert_equal ["minus"], @lexer.run("-")
  end

  def test_real_input
    assert_equal %w{123 plus 321 minus plus 12}, @lexer.run("123+321-+12")
  end
end
