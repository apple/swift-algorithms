#  Contains

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Contains.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/ContainsTests.swift)]

Test containment of the elements of one collection in another.

```swift
let string = "foo, bar, foo, bar"

if let range = string.firstRange(of: "bar") {
    print(string[..<range.lowerBound]) // "foo, "
    print(string[range])               // "bar"
    print(string[range.upperBound...]) // ", foo, bar"
}

if let range = string.lastRange(of: "foo") {
    print(string[..<range.lowerBound]) // "foo, bar, "
    print(string[range])               // "foo"
    print(string[range.upperBound...]) // ", bar"
}

print(string.contains("bar, foo")) // true
print(string.contains("foo, foo")) // false
```

## Detailed Design

All of the included methods take an equivalence function that can be left out
when the element type conforms to `Equatable`.

`contains(_:)` and `firstRange(of:)` are available on collections and take a
second collection as its argument. `lastRange(of:)` requires that both
collections are bidirectional.

```swift
extension Collection {
  public func contains<Other: Collection>(
    _ other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> Bool
}

extension Collection where Element: Equatable {
  public func contains<Other: Collection>(
    _ other: Other
  ) -> Bool where Other.Element == Element
}

extension Collection {
  public func firstRange<Other: Collection>(
    of other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> Range<Index>?
}

extension Collection where Element: Equatable {
  public func firstRange<Other: Collection>(of other: Other) -> Range<Index>?
    where Other.Element == Element
}

extension BidirectionalCollection {
  public func lastRange<Other: BidirectionalCollection>(
    of other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> Range<Index>?
}

extension BidirectionalCollection where Element: Equatable {
  public func lastRange<Other: BidirectionalCollection>(
    of other: Other
  ) -> Range<Index>? where Other.Element == Element
}
```

### Complexity

All three methods have worst-case performance of O(*m \* n*), where *m* is the
length of the collection being searched, and *n* is the length of the collection
being searched for.
