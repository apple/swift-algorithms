# FirstNonNil

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/FirstNonNil.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/FirstNonNilTests.swift)]

Retrieves the first `.some` encountered while applying the given transform.

This operation is available through the `firstNonNil(_:)` method on any sequence.

```swift
let value = ["A", "B", "10"].firstNonNil { Int($0) }
// value == .some(10)
// 
let noValue = ["A", "B", "C"].firstNonNil { Int($0) }
// noValue == .none
```


This method is analogous to `first(where:)` in how it only consumes values until
a `.some` is found, unlike using lazy operators, which will load any sequence into a collection
before evaluating its transforms lazily.

## Detailed Design

The `firstNonNil(_:)` method is added as an extension method on the `Sequence`
protocol:

```swift
public extension Sequence {
    func firstNonNil<Result>(_ transform: (Element) throws -> Result?)
    rethrows -> Result? 
}

```

### Naming

This method’s name was selected for its comprehensibility. 

### Comparison with other languages

**Scala**: Scala provides a `collectFirst` function that finds the first element
in a collection for which a partial function is defined.
