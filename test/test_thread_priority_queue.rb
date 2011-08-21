require 'test/unit'

lib_dir = File.dirname(__FILE__)+'/../lib'
$:.unshift lib_dir unless $:.include? lib_dir

require 'thread_priority_queue'

module TestPriorityQueueCommon

  def test_length_is_zero
    assert_equal 0, @q.length, "length should initially be 0"
  end

  def test_pop_hihgest_priority_first
    @q.push "a", 1
    @q.push "b", 2
    assert_equal 2, @q.length
    # Test that items comes out in prioritized order.
    assert_equal "b", @q.pop
    assert_equal "a", @q.pop
  end

  def test_pop_fifo_at_same_priority
    @q.push "a", 1
    @q.push "b", 1
    assert_equal 2, @q.length
    # Test that items comes out in fifo order.
    assert_equal "a", @q.pop
    assert_equal "b", @q.pop
  end

  def test_left_shift_must_be_obj_prio_tuple
    @q << [ 'a', 2 ] 
    @q << [ 'b', 1 ]
    assert_equal 2, @q.length
    # Test that items comes out in prioritized order.
    assert_equal "a", @q.pop
    assert_equal "b", @q.pop
  end

  def test_left_shift_argument_error
    assert_raises(ArgumentError) {
      @q << [ 'a' ]
    }
  end

  def test_binary_search_is_private
    assert_raises(NoMethodError) { @q.find_first_of 0 }
    assert_raises(NoMethodError) { @q.priority_at_index 0 }
  end

end

class TestPriorityQueueBase < Test::Unit::TestCase
  include TestPriorityQueueCommon

  def setup
    @q = PriorityQueue.new
  end

end

class TestSizedPriorityQueue < Test::Unit::TestCase
  include TestPriorityQueueCommon

  def setup
    @q = SizedPriorityQueue.new(2)
  end

  def test_max
    assert_equal 2, @q.max
  end

  # TODO
  #def test_block_on_queue_full
  #end

end
