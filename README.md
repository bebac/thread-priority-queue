Thread Priority Queues
----------------------

Pure ruby implementation of thread priority queue. Inherits from Queue and keeps the @que instance
variable sorted. A binary search for the insertion point is done on push. The runtime characteristics
are:

push - O(logn) (assuming Array random accces is O(1))
pop - O(1)

The performance is not great if you compare with what can be accomplished with c extensions, but 
for relatively small sizes (N < ~100000) it will probably do the trick.

## Example

    require 'thread'
    require 'thread_priority_queue'

    q = PriorityQueue.new

    q.push 'a', 2
    q.push 'b', 1
    q.push 'c', 3

    q.pop # => 'c'

    # or using left shift operator.
 
    q << [ 'd', 4 ]

    q.pop # => 'd'
