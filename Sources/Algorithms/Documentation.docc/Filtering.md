# Filtering

Remove duplicated elements or strip the `nil` values from a sequence or collection. 

## Overview

Use the _uniquing_ methods to remove duplicates from a sequence or collection, or to remove elements that have a duplicated property. 

```swift
let numbers = [1, 2, 3, 3, 2, 3, 3, 2, 2, 2, 1]

let unique = numbers.uniqued()
// Array(unique) == [1, 2, 3]
```

The `compacted()` method removes all `nil` values from a sequence or collection of optionals: 

```swift
let array: [Int?] = [10, nil, 30, nil, 2, 3, nil, 5]
let withNoNils = array.compacted()
// Array(withNoNils) == [10, 30, 2, 3, 5]
```

## Topics

### Uniquing Elements

- ``Swift/Sequence/uniqued()``
- ``Swift/Sequence/uniqued(on:)``
- ``Swift/LazySequenceProtocol/uniqued(on:)``

### Filtering out `nil` Elements

- ``Swift/Collection/compacted()``
- ``Swift/Sequence/compacted()``

### Supporting Types

- ``UniquedSequence``
- ``CompactedSequence``
- ``CompactedCollection``
