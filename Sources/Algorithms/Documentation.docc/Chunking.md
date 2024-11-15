# Chunking

Break collections into consecutive chunks by length, count, or based on closure-based logic.

## Overview

_Chunking_ is the process of breaking a collection into consecutive subsequences, without dropping or duplicating any of the collection's elements. After chunking a collection, joining the resulting subsequences produces the original collection of elements, unlike _splitting_, which consumes the separator element(s).

```swift
let names = ["Ji-sun", "Jin-su", "Min-jae", "Young-ho"]
let evenlyChunked = names.chunks(ofCount: 2)
// ~ [["Ji-sun", "Jin-su"], ["Min-jae", "Young-ho"]] 

let chunkedByFirstLetter = names.chunked(on: \.first)
// equivalent to [("J", ["Ji-sun", "Jin-su"]), ("M", ["Min-jae"]), ("Y", ["Young-ho"])]
```

## Topics

### Chunking a Collection by Count

- ``Swift/Collection/chunks(ofCount:)``
- ``Swift/Collection/evenlyChunked(in:)``

### Chunking a Collection by Predicate

- ``Swift/Collection/chunked(by:)``
- ``Swift/LazySequenceProtocol/chunked(by:)``

### Chunking a Collection by Subject

- ``Swift/Collection/chunked(on:)``
- ``Swift/LazySequenceProtocol/chunked(on:)``

### Supporting Types

- ``ChunkedByCollection``
- ``ChunkedOnCollection``
- ``ChunksOfCountCollection``
- ``EvenlyChunkedCollection``
