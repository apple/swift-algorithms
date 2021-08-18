#  Joined

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Joined.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/JoinedTests.swift)]

Concatenate a sequence of sequences, inserting a separator between each element.

The separator can be either a single element or a sequence of elements, and it
can optionally depend on the sequences right before and after it by returning it
from a closure:

```swift
for number in [[1], [2, 3], [4, 5, 6]].joined(by: 100) {
    print(number)
}
// 1, 100, 2, 3, 100, 4, 5, 6

for number in [[10], [20, 30], [40, 50, 60]].joined(by: { [$0.count, $1.count] }) {
    print(number)
}
// 10, 1, 2, 20, 30, 2, 3, 40, 50, 60
```

## Detailed Design

The versions that take a closure are executed eagerly and are defined on
`Sequence`:

```swift
extension Sequence where Element: Sequence {
    public func joined(
        by separator: (Element, Element) throws -> Element.Element
    ) rethrows -> [Element.Element]
    
    public func joined<Separator>(
        by separator: (Element, Element) throws -> Separator
    ) rethrows -> [Element.Element]
        where Separator: Sequence, Separator.Element == Element.Element
}
```

The versions that do not take a closure are defined on both `Sequence` and
`Collection` because the resulting collections need to precompute their start
index to ensure O(1) access:

```swift
extension Sequence where Element: Sequence {
    public func joined(by separator: Element.Element)
        -> JoinedBySequence<Self, CollectionOfOne<Element.Element>>
        
    public func joined<Separator>(
        by separator: Separator
    ) -> JoinedBySequence<Self, Separator>
        where Separator: Collection, Separator.Element == Element.Element
}

extension Collection where Element: Sequence {
    public func joined(by separator: Element.Element)
        -> JoinedByCollection<Self, CollectionOfOne<Element.Element>>
        
    public func joined<Separator>(
        by separator: Separator
    ) -> JoinedByCollection<Self, Separator>
        where Separator: Collection, Separator.Element == Element.Element
}
```

Note that the sequence separator of the closure-less version defined on
`Sequence` is required to be a `Collection`, because a plain `Sequence` cannot in
general be iterated over multiple times.

The closure-based versions also have lazy variants that are defined on both
lazy sequences and collections for the same reason as explained above:

```swift
extension LazySequenceProtocol where Element: Sequence {
    public func joined(
        by separator: @escaping (Element, Element) -> Element.Element
    ) -> JoinedByClosureSequence<Self, CollectionOfOne<Element.Element>>
  
    public func joined<Separator>(
        by separator: @escaping (Element, Element) -> Separator
    ) -> JoinedByClosureSequence<Self, Separator>
}

extension LazySequenceProtocol where Self: Collection, Element: Collection {
    public func joined(
        by separator: @escaping (Element, Element) -> Element.Element
    ) -> JoinedByClosureCollection<Self, CollectionOfOne<Element.Element>>
  
    public func joined<Separator>(
        by separator: @escaping (Element, Element) -> Separator
    ) -> JoinedByClosureCollection<Self, Separator>
}
```

`JoinedBySequence`, `JoinedByClosureSequence`, `JoinedByCollection`, and
`JoinedByClosureCollection` conform to `LazySequenceProtocol` when the base
sequence conforms. `JoinedByCollection` and `JoinedByClosureCollection` also
conform to `BidirectionalCollection` when the base collection conforms.
