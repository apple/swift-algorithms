# Windows

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Windows.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/WindowsTests.swift)]

Break a collection into overlapping contiguous window subsequences where
elements are slices from the original collection.

The `windows(size:)` method takes in a integer size and returns a collection of 
subsequences.

```swift
let swift = "swift"

let windowed = swift.windows(size: 2) 
// windowed == [ "sw", "wi", "if", "ft" ]
```

## Detailed Design

The `windows(size:)` is added as a method on an extension of  `Collection`

```swift
extension Collection {
  public func windows(size: Int) -> Windows<Self> {
    Windows(base: self, size: size)
  }
}
```

If a size larger than the collection length is specified, an empty collection is returned. 
The first upper bound is computed eagerly because it determines if the collection 
`startIndex` returns `endIndex`. 

```swift
[1, 2, 3].windows(size: 5).isEmpty // true
```

The resulting `Windows` type is a collection, with conditional conformance to the 
`BidirectionalCollection`, and `RandomAccessCollection`  when the base collection
conforms.

### Complexity

The call to `windows(size: k)` is O(_k_) and access to the next window is O(_1_). If the base 
collection conforms to `RandomAccessCollection` then both are O(_1_).

### Naming

The name `window` is adopted from the the commonly known sliding windows problem 
or algorithm name. Alternatively this could be named `slidingWindows`, however I did 
not feel the verbosity here was necessary.

### Comparison with other languages

[rust](https://doc.rust-lang.org/std/slice/struct.Windows.html) has 
`std::slice::Windows`  which is a method available on slices. It has the same 
semantics as described here.
