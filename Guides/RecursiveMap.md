# RecursiveMap

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/RecursiveMap.swift) |
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/RecursiveMapTests.swift)]

Produces a sequence containing the original sequence followed by recursive mapped sequence.

```swift
struct View {
    var id: Int
    var children: [View] = []
}
let tree = [
    View(id: 1, children: [
        View(id: 3),
        View(id: 4, children: [
            View(id: 6),
        ]),
        View(id: 5),
    ]),
    View(id: 2),
]
for view in tree.recursiveMap({ $0.children }) {
    print(view.id)
}
// 1
// 2
// 3
// 4
// 5
// 6
```

## Detailed Design

The `recursiveMap()` method is declared as `Sequence` extensions, and return `RecursiveMapSequence` instance:

```swift
extension Sequence {
    public func recursiveMap<S>(
        _ transform: @escaping (Element) -> S
    ) -> RecursiveMapSequence<Self, S>
}
```

### Complexity

Calling this method is O(_1_).
