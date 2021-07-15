# Padded

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Padded.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/PaddedTests.swift)]

Pads a collection to the specified length using the provided padding element.

```swift
let paddedNumber = "96".prefixPadded(with: "0", toCount: 4)
// String(paddedNumber) == "0096"

let data: [UInt8] = [0xde, 0xad, 0xbe, 0xef]
let paddedData = data.suffixPadded(with: 0, toCount: 16)
// Data(paddedData) contains 16 bytes
```

## Detailed Design

Two new methods are added to collections:

```swift
extension Collection {
    func prefixPadded(
        with element: Element,
        toCount paddingLength: Int
    ) -> PrefixPadded<Self>

    func suffixPadded(
        with element: Element,
        toCount paddingLength: Int
    ) -> SuffixPadded<Self>
}
```

The two variants of the padded methods extend the base collection to the provided 
count by padding it with the padding element at the start for `prefixPadded` and 
at the end for `suffixPadded.`

### Complexity

Calling these methods is O(_1_).

### Naming

This operation is commonly referred to as left-padding or right padding on strings 
or other collection types (e.g. `numpy.pad()`). The name has been adapted to better
fit in with the Swift naming convention for operators on collections (e.g. 
`trimSuffix`, `suffix(_ maxLength:)`, `prefix(upTo:)`, etc.).

### Comparison with other languages

**Python:** Python’s built-in `str`, `bytes` and `bytearray` have `ljust` and 
`rjust` methods.
