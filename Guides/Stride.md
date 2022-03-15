# Stride

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Stride.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/StrideTests.swift)]

Step over the elements of a sequence elements by a specified amount.

This is available through the `striding(by:)` method on any `Sequence`.

```swift
(0...10).striding(by: 2) // == [0, 2, 4, 6, 8, 10]
```

If the stride is larger than the length of the sequence, the resulting wrapper
only contains the first element.

The stride amount must be a positive value.

## Detailed Design

The `striding(by:)` method is declared in extension of both `Sequence` and
`Collection`:

```swift
extension Sequence {
    public func striding(by step: Int) -> StridingSequence<Self>
}

extension Collection {
    public func striding(by step: Int) -> StridingCollection<Self>
}
```

The reason for this distinction is subtle. The `StridingSequence.Iterator` type
is unable to skip over multiple elements of the wrapped iterator at once since
that's not part of `IteratorProtocol`'s interface. In order to efficiently
stride over collections that provide a fast way of skipping multiple elements at
once, the `StridingCollection` type was added which does not provide a custom
`Iterator` type and therefore always strides over the underlying collection in
the fastest way possible. See the related
[GitHub issue](https://github.com/apple/swift-algorithms/issues/63) for more
information.

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
