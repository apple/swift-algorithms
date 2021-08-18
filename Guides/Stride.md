# Stride

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Stride.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/StrideTests.swift)]

A type that steps over sequence elements by the specified amount.

This is available through the `striding(by:)` method on any `Sequence`.

```swift
(0...10).striding(by: 2) // == [0, 2, 4, 6, 8, 10]
```

If the stride is larger than the count, the resulting wrapper only contains the 
first element.

The stride amount must be a positive value.

## Detailed Design

The `striding(by:)` method is declared as a `Sequence` extension, and returns a 
`StridingSequence` type:

```swift
extension Sequence {
  public func striding(by step: Int) -> StridingSequence<Self>
}
```

A custom `Index` type is defined so that it's not possible to get confused when 
trying to access an index of the stride collection.

```swift
[0, 1, 2, 3, 4].striding(by: 2)[1] // == 1
[0, 1, 2, 3, 4].striding(by: 2).map { $0 }[1] // == 2
```

A careful thought was given to the composition of these strides by giving a 
custom implementation to `index(_:offsetBy:limitedBy)` which multiplies the 
offset by the stride amount. 

```swift
base.index(i.base, offsetBy: distance * stride, limitedBy: base.endIndex)
```

The following two lines of code are equivalent, including performance:

```swift
(0...10).striding(by: 6)
(0...10).striding(by: 2).stride(by: 3)
```

### Complexity

The call to `striding(by: k)` is always O(_1_) and access to the next value in
the stride is O(_1_) if the collection conforms to `RandomAccessCollection`, 
otherwise O(_k_).

### Comparison with other languages

[rust has `Strided`](https://docs.rs/strided/0.2.9/strided/) available in a crate. 
[c++ has std::slice::stride](http://www.cplusplus.com/reference/valarray/slice/stride/)

The semantics of `striding` described in this documentation are equivalent.
