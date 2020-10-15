# SlidingWindows

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/SlidingWindows.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/SlidingWindowsTests.swift)]

Break a collection into overlapping contiguous window subsequences where
elements are slices from the original collection.

The `slidingWindows(ofCount:)` method takes in a integer size and returns a collection 
of subsequences.

```swift
let swift = "swift"

let windowed = swift.slidingWindows(ofCount: 2) 
// windowed == [ "sw", "wi", "if", "ft" ]
```

## Detailed Design

The `slidingWindows(ofCount:)` is added as a method on an extension of  `Collection`

```swift
extension Collection {
  public func slidingWindows(ofCount count: Int) -> SlidingWindows<Self> {
    SlidingWindows(base: self, size: count)
  }
}
```

If a size larger than the collection length is specified, an empty collection is returned. 
The first upper bound is computed eagerly because it determines if the collection 
`startIndex` returns `endIndex`. 

```swift
[1, 2, 3].slidingWindows(ofCount: 5).isEmpty // true
```

The resulting `SlidingWindows` type is a collection, with conditional conformance to the 
`BidirectionalCollection`, and `RandomAccessCollection`  when the base collection
conforms.

### Complexity

The call to `slidingWindows(ofCount: k)` is O(_1_) if the collection conforms to 
`RandomAccessCollection`, otherwise O(_k_). Access to the next window is O(_1_).

### Naming

The type `SlidingWindows` takes its name from the algorithm, similarly the method takes
it's name from it too  `slidingWindows(ofCount: k)`. 

The label on the method `ofCount` was chosen to create a consistent feel to the API 
available in swift-algorithms repository. Inspiration was taken from 
`combinations(ofCount:)` and  `permutations(ofCount:)`.

Previously the name `windows` was considered but was deemed to potentially create 
ambiguity with the Windows operating system. 

### Comparison with other languages

[rust](https://doc.rust-lang.org/std/slice/struct.Windows.html) has 
`std::slice::Windows`  which is a method available on slices. It has the same 
semantics as described here.
