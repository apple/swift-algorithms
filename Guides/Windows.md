# Windows

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Windows.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/WindowsTests.swift)]

Break a collection into overlapping subsequences where
elements are slices from the original collection.

The `windows(ofCount:)` method takes a size as a parameter and returns a
collection of subsequences. Each element of the returned collection is a
successive overlapping slice of the given size.

```swift
let swift = "swift"

let windowed = swift.windows(ofCount: 2) 
// Array(windowed) == [ "sw", "wi", "if", "ft" ]
```

## Detailed Design

The `windows(ofCount:)` method is added as an extension `Collection` method:

```swift
extension Collection {
    public func windows(ofCount count: Int) -> WindowsCollection<Self>
}
```

If a size larger than the collection's length is specified, the returned
collection is empty. 

```swift
[1, 2, 3].windows(ofCount: 5).isEmpty // true
```

The resulting `WindowsCollection` type is a collection, with conditional
conformance to the `BidirectionalCollection`, `RandomAccessCollection`, and
`LazyCollectionProtocol` protocols when the base collection conforms.

### Complexity

The call to `windows(ofCount: k)` is O(1) if the collection conforms to 
`RandomAccessCollection`, otherwise O(_k_). Access to each successive window is 
O(1).

### Naming

The method and type name take their names from the sliding windows algorithm.

The `ofCount` parameter label was chosen to create a consistent feel with other 
APIs in the `Algorithms` package, specifically with `combinations(ofCount:)` 
and  `permutations(ofCount:)`.

### Comparison with other languages

[rust](https://doc.rust-lang.org/std/slice/struct.Windows.html) has 
`std::slice::Windows` which is a method available on slices. It has the same 
semantics as described here.
