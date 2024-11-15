# ``Algorithms``

**Swift Algorithms** is an open-source package of sequence and collection algorithms, 
along with their related types.

## Overview

The Algorithms package provides a variety of sequence and collection operations, letting you cycle over a collection's elements, find combinations and permutations, create a random sample, and more.

For example, the package includes a group of "chunking" methods, each of which breaks a collection into consecutive subsequences. One version tests adjacent elements to find the breaking point between chunks — you can use it to quickly separate an array into ascending runs:

```swift
let numbers = [10, 20, 30, 10, 40, 40, 10, 20]
let chunks = numbers.chunked(by: { $0 <= $1 })
// [[10, 20, 30], [10, 40, 40], [10, 20]]
```

Another version looks for a change in the transformation of each successive value. You can use that to separate a list of names into groups by the first character:

```swift
let names = ["Cassie", "Chloe", "Jasmine", "Jordan", "Taylor"]
let chunks = names.chunked(on: \.first)
// [["Cassie", "Chloe"], ["Jasmine", "Jordan"], ["Taylor"]]
```

Explore more chunking methods and the remainder of the Algorithms package, grouped in the following topics.

## Topics

- <doc:CombinationsPermutations>
- <doc:SlicingSplitting>
- <doc:Chunking>
- <doc:Joining>
- <doc:Extending>
- <doc:Trimming>
- <doc:Keying>
- <doc:Sampling>
- <doc:MinAndMax>
- <doc:Selecting>
- <doc:Filtering>
- <doc:Reductions>
- <doc:Partitioning>
