require 'thread'

class PriorityQueue
  #
  # Creates a new queue.
  #
  def initialize
    @que = []
    @waiting = []
    @que.taint          # enable tainted communication
    @waiting.taint
    self.taint
    @mutex = Mutex.new
  end

  #
  # Pushes +obj+ to the queue at priority +prio+.
  #
  def push(obj, prio)
    @mutex.synchronize{
      @que.insert find_first_of(prio), [ obj, prio ]
      begin
        t = @waiting.shift
        t.wakeup if t
      rescue ThreadError
        retry
      end
    }
  end

  def <<(obj_prio_tuple)
    push *obj_prio_tuple
  end

  #
  # Alias of push
  #
  alias enq push

  #
  # Retrieves data from the queue.  If the queue is empty, the calling thread is
  # suspended until data is pushed onto the queue.  If +non_block+ is true, the
  # thread isn't suspended, and an exception is raised.
  #
  def pop(non_block=false)
    @mutex.synchronize{
      while true
        if @que.empty?
          raise ThreadError, "queue empty" if non_block
          @waiting.push Thread.current
          @mutex.sleep
        else
          return @que.pop[0]
        end
      end
    }
  end

  #
  # Alias of pop
  #
  alias shift pop
  alias deq pop

  #
  # Returns +true+ if the queue is empty.
  #
  def empty?
    @que.empty?
  end

  #
  # Removes all objects from the queue.
  #
  def clear
    @que.clear
  end

  #
  # Returns the length of the queue.
  #
  def length
    @que.length
  end

  #
  # Alias of length.
  #
  alias size length

  #
  # Returns the number of threads waiting on the queue.
  #
  def num_waiting
    @waiting.size
  end

  protected

  def find_first_of(priority, range=(0..length))
    if range.begin == range.end
      range.begin
    else
      center = (range.end-range.begin)/2
      if priority > priority_at_index(range.begin+center)
        find_first_of priority, (range.end-center..range.end)
      else
        find_first_of priority, (range.begin..range.begin+center)
      end
    end
  end

  def priority_at_index(index)
    @que[index][1]
  end

end

class SizedPriorityQueue < PriorityQueue
  #
  # Creates a fixed-length queue with a maximum size of +max+.
  #
  def initialize(max)
    raise ArgumentError, "queue size must be positive" unless max > 0
    @max = max
    @queue_wait = []
    @queue_wait.taint		# enable tainted comunication
    super()
  end

  #
  # Returns the maximum size of the queue.
  #
  def max
    @max
  end

  #
  # Sets the maximum size of the queue.
  #
  def max=(max)
    diff = nil
    @mutex.synchronize {
      if max <= @max
        @max = max
      else
        diff = max - @max
        @max = max
      end
    }
    if diff
      diff.times do
	begin
	  t = @queue_wait.shift
	  t.run if t
	rescue ThreadError
	  retry
	end
      end
    end
    max
  end

  #
  # Pushes +obj+ to the queue.  If there is no space left in the queue, waits
  # until space becomes available.
  #
  def push(obj, prio)
    @mutex.synchronize{
      while true
        break if @que.length < @max
        @queue_wait.push Thread.current
        @mutex.sleep
      end

      @que.insert find_first_of(prio), [ obj, prio ]
      begin
        t = @waiting.shift
        t.wakeup if t
      rescue ThreadError
        retry
      end
    }
  end

  def <<(obj_prio_tuple)
    push *obj_prio_tuple
  end

  #
  # Alias of push
  #
  alias enq push

  #
  # Retrieves data from the queue and runs a waiting thread, if any.
  #
  def pop(*args)
    retval = super
    @mutex.synchronize {
      if @que.length < @max
        begin
          t = @queue_wait.shift
          t.wakeup if t
        rescue ThreadError
          retry
        end
      end
    }
    retval
  end

  #
  # Alias of pop
  #
  alias shift pop
  alias deq pop

  #
  # Returns the number of threads waiting on the queue.
  #
  def num_waiting
    @waiting.size + @queue_wait.size
  end

end
