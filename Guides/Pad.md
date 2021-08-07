# Pad

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Pad.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/PadTests.swift)]

Pad a collection by repeatedly adding a padding element to the start or end until 
it reaches a given length.

```swift
let paddedNumber = "96".paddingStart(with: "0", toCount: 4)
// paddedNumber == "0096"

let data = Data([0xde, 0xad, 0xbe, 0xef])
let paddedData = data.paddingEnd(with: 0, toCount: 16)
// paddedData contains 16 bytes
```

## Detailed Design

Two new operations, `paddingStart` and `paddingEnd` have been introduced to
`RangeReplaceableCollection`.

```swift
extension RangeReplaceableCollection {
    public func paddingStart(
        with element: Element,
        toCount paddedCount: Int
    ) -> Self
  
    public func paddingEnd(
        with element: Element,
        toCount paddedCount: Int
    ) -> Self
}
```

Each of the two operations also has a mutating variant.

```swift
extension RangeReplaceableCollection {
    public mutating func padStart(
        with element: Element,
        toCount paddedCount: Int)
      
    public mutating func padEnd(
        with element: Element,
        toCount paddedCount: Int)
}
```

Padding a collection expands the collection to the desired length by repeating 
the padding element at the start or the end. In case the collection's length is 
greater than the `paddedCount`, the collection is preserved.

### Complexity

O(_m_), when the collection's length is less than the `paddedCount`, where _m_ is the 
`paddedCount`. O(_n_) when the collection's length is greater than or equal to the 
`paddedCount`, where _n_ is the length of the collection. For a `RandomAccessCollection`
when the collection's length is greater than or equal to the `paddedCount`, the 
complexity is reduced to O(_1_).

### Naming

This operation is commonly referred to as left-padding or right-padding on strings 
or other collection types (e.g. `numpy.pad()`). The name has been adapted to better
fit in with Swift's naming convention.

### Comparison with other languages

**Python:** Python’s built-in `str`, `bytes` and `bytearray` have `ljust` and 
`rjust` methods.
**Ruby:** Ruby defines `ljust` and `rjust` on strings.
**JavaScript:** `String.prototype.padStart` and `String.prototype.padEnd` are part
of the ECMAScript standard and supported on all prominent web browsers.
