# First Non-Nil

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/FirstNonNil.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/FirstNonNilTests.swift)]
 
Returns the first non-`nil` result obtained from applying the given
transformation to the elements of the sequence.

```swift
let strings = ["three", "3.14", "-5", "2"]
if let firstInt = strings.firstNonNil({ Int($0) }) {
    print(firstInt)
    // -5
}
```

Like `first(where:)`, this method stops iterating the sequence once a match is
found. Use `firstNonNil(_:)` to avoid having to apply a transformation twice:

```swift
let strings = ["three", "3.14", "-5", "2"]
if let firstIntAsString = strings.first(where: { Int($0) != nil }) {
    let firstInt = Int(firstIntAsString)! // :(
    // ...
}
```

This method's behavior can also be approximated using `compactMap(_:)`:

```swift
let strings = ["three", "3.14", "-5", "2"]
if let firstInt = strings.compactMap({ Int($0) }).first {
    // ...
}
```

However, unlike `firstNonNil(_:)` and `first(where:)`, `compactMap(_:)` does not
stop iterating the sequence once the first match is found. Adding `.lazy` fixes
this, at the cost of requiring an escaping closure that you cannot `throw` from:

```swift
let strings = ["three", "3.14", "-5", "2"]
if let firstInt = strings.lazy.compactMap({ Int($0) }).first {
    // ...
}
```

## Detailed Design

The `firstNonNil(_:)` method is added as an extension method on the `Sequence`
protocol:

```swift
public extension Sequence {
    func firstNonNil<Result>(
        _ transform: (Element) throws -> Result?
    ) rethrows -> Result?
}
```

### Complexity

`firstNonNil(_:)` is an O(*n*) operation, where *n* is the number of
elements at the start of the sequence that result in `nil` when applying the
transformation.

### Naming

Some alternative names were considered:

* `compactMapFirst(_:)`
* `first(mapping:)`
* `firstSome(_:)`
* `firstMap(_:)`

### Comparison with other languages

**Haskell**: Haskell includes the `firstJust` method, which has the same
semantics as the `firstNonNil(_:)` method.

**Rust**: Rust includes the `find_map` method, which has the same semantics as
the `firstNonNil(_:)` method.

**Scala**: Scala includes the `collectFirst` method, which has the same
semantics as the `firstNonNil(_:)` method.
