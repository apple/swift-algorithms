# Partitioning and Rotating

Partition a collection according to a unary predicate,
rotate a collection around a particular index,
or find the index where a collection is already partitioned.

## Overview

A _stable partition_ maintains the relative order of elements within both partitions.

```swift
// partition(by:) - unstable ordering
var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
let p1 = numbers.partition(by: { $0.isMultiple(of: 20) })
// p1 == 4
// numbers == [10, 70, 30, 50, 40, 60, 20, 80]
//                             ^ start of second partition

// stablePartition(by:) - maintains relative ordering
numbers = [10, 20, 30, 40, 50, 60, 70, 80]
let p2 = numbers.stablePartition(by: { $0.isMultiple(of: 20) })
// p2 == 4
// numbers == [10, 30, 50, 70, 20, 40, 60, 80]
//                             ^ start of second partition
```

Use the `rotate` method to shift the elements of a collection to start at a new position, moving the displaced elements to the end: 

```swift
var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
let p = numbers.rotate(toStartAt: 2)
// numbers == [30, 40, 50, 60, 70, 80, 10, 20]
// p == 6 -- numbers[p] == 10
```

## Topics

### Stable Partition

- ``Swift/MutableCollection/stablePartition(by:)``
- ``Swift/MutableCollection/stablePartition(subrange:by:)``
- ``Swift/Sequence/partitioned(by:)``
- ``Swift/Collection/partitioned(by:)``

### Partition of Subranges

- ``Swift/MutableCollection/partition(subrange:by:)-5vdh7``
- ``Swift/MutableCollection/partition(subrange:by:)-4gpqz``

### Finding a Partition Index

- ``Swift/Collection/partitioningIndex(where:)``

### Rotation

- ``Swift/MutableCollection/rotate(toStartAt:)-9fp48``
- ``Swift/MutableCollection/rotate(toStartAt:)-2r55j``
- ``Swift/MutableCollection/rotate(subrange:toStartAt:)-ov6a``
- ``Swift/MutableCollection/rotate(subrange:toStartAt:)-5teoq``

### Reversing

- ``Swift/MutableCollection/reverse(subrange:)``
