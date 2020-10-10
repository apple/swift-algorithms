# Heap

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Heap.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/AlgorithmsTests/HeapTests.swift)]

A type that provides a heap view of a collection’s elements, or of a subset of those 
elements. 

The heap view puts the maximum element (defined by the provided comparator
closure) at subscript 0 in the heap, and ensures that when `pop()` is called that
the maximum is removed and retrieved and that the new maximum is moved to 
subscript 0. The heap property, where each node in the tree is greater than its children,
is preserved by the heap operations. 

The heap does not alter the underlying collection. Multiple heaps can refer to the 
same collection at the same time. But if the underlying collection is mutated, any heaps
that refer to it will become invalid. 

By calling the `pop()` method repeatedly a client can retrieve the elements of 
the collection in order according to the comparator without sorting the whole collection. 

```swift
let characters = "Woven silk pyjamas exchanged for blue quartz."

let comparators : [(Character, Character) -> Bool] =
  [{$0 <= $1},
   {$1 <= $0}]
   
for comparator in comparators {
  var heap = Heap(arrayUnderTest, comparator: comparator)

  var oldChar: Character? = .none
  while let newchar = heap.pop() {
    oldChar = newchar
    print(newchar)
  }
}
```
will print the characters from `z` down to ` `, including duplicates, then will print
the characters in ascending order, from ` ` to `z` again. 

The comparator is a closure with type `(Base.Element, Base.Element) -> Bool`. 
It should return true if the left-hand argument is less-than to the right-hand 
argument according to the partial ordering you want for the heap.  

## Detailed Design

The `heap(comparator:)` method is declared as a `Collection` extension and 
returns a `Heap` type. The `Element` of the collection does not need to conform to 
`Comparable`:

```swift
extension Collection {
  public func heap(comparator: @escaping (Element, Element) -> Bool) 
                -> Heap<Self> {
    return Heap(self, comparator: comparator)
  }
}
```

The `Heap` type itself is a struct that can be subscripted but does not conform to any 
protocols. 

The `Heap` stores an array of the indexes to the underlying collection, so it requires 
storage for an `Array<Base.Index>` with `base.count` elements. 

### Complexity

Calling `heap()` is an _O(n)_ operation, where _n_ is the number of elements in the 
base collection.

Calling `pop` is an _O(lg n)_ operation, where _lg_ is the base 2 log and _n_ in this case
is the number of remaining elements in the permutation index. (This is proportional to 
`base.count` so _n_ could be the number of elements in the base collection.)

### Naming

The `Heap` name is common, but it does reveal the underlying implementation. There
are some Swift Evolution pitches using different names. The advantage to this name is 
that the implementation and its specific complexity are clear. 

The actual heap itself is a data structure--it's possible that this should be part of a 
hypothetical `DataStructures` package. 

Another approach would be to make `Heap` conform to  `IteratorProtocol`, 
and then to have the `next()` method extract and remove the top element in the heap. 
That would interoperate with some `for...in` loops. 

### Comparison with other langauges

**C++:** The `<algorithm>` library defines `make_heap` and a variety of other heap-maintenance
operations. 

**Rust/Ruby/Python:** _I have not looked yet, but I believe that Ruby and Python 
do not have a partially-sorted kind of thing._

