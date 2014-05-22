require "minitest/autorun"
require_relative "../lib/stack_frame"

class TestStackFrame < MiniTest::Test
  def test_set_next_register_returns_a_register
    stack_frame = StackFrame.new
    assert_equal stack_frame.set_next_register("id"), "$s0"
  end

  def test_set_next_register_increments_the_index
    stack_frame = StackFrame.new
    stack_frame.set_next_register("foo")
    assert_equal stack_frame.set_next_register("id"), "$s1"
  end

  def test_get_register
    stack_frame = StackFrame.new
    stack_frame.set_next_register("id")
    assert_equal stack_frame.get_register("id"), "$s0"
  end

  def test_save_registers_mips
    stack_frame = StackFrame.new
    stack_frame.set_next_register("id")
    expected = [
      "addi $sp, $sp, -4",
      "sw $s0, 0($sp)"
    ].join("\n")
    save_registers = stack_frame.save_registers_mips
    assert_equal save_registers.to_s, expected

    s = StackFrame::SaveRegistersMips.new(3)
    expected = [
      "addi $sp, $sp, -12",
      "sw $s0, 0($sp)",
      "sw $s1, 4($sp)",
      "sw $s2, 8($sp)"
    ].join("\n")

    assert_equal s.to_s, expected
  end

  def test_restore_registers_mips
    stack_frame = StackFrame.new
    stack_frame.set_next_register("id")
    expected = [
      "lw $s0, 0($sp)",
      "addi $sp, $sp, 4"
    ].join("\n")
    restore_registers = stack_frame.restore_registers_mips
    assert_equal restore_registers.to_s, expected

    s = StackFrame::RestoreRegistersMips.new(3)
    expected = [
      "lw $s0, 0($sp)",
      "lw $s1, 4($sp)",
      "lw $s2, 8($sp)",
      "addi $sp, $sp, 12"
    ].join("\n")

    assert_equal s.to_s, expected
  end

  def test_has_memory_offset_for?
    stack_frame = StackFrame.new
    stack_frame.add_field("property1")
    assert stack_frame.has_field_offset_for?("property1")
  end

  def test_field_offset
    stack_frame = StackFrame.new
    stack_frame.add_field("property1")
    stack_frame.add_field("property2")
    assert_equal stack_frame.field_offset("property1"), 0
    assert_equal stack_frame.field_offset("property2"), 4
  end

  def test_frame_offset
    stack_frame = StackFrame.new
    stack_frame.add_parameter("property1")
    stack_frame.add_parameter("property2")
    assert_equal stack_frame.frame_offset("property1"), 0
    assert_equal stack_frame.frame_offset("property2"), 4
  end
end
