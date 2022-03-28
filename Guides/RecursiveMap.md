# RecursiveMap

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/RecursiveMap.swift) |
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/RecursiveMapTests.swift)]

Produces a sequence containing the original sequence followed by recursive mapped sequence.

```swift
struct Node {
    var id: Int
    var children: [Node] = []
}
let tree = [
    Node(id: 1, children: [
        Node(id: 3),
        Node(id: 4, children: [
            Node(id: 6),
        ]),
        Node(id: 5),
    ]),
    Node(id: 2),
]
for node in tree.recursiveMap({ $0.children }) {
    print(node.id)
}
// 1
// 2
// 3
// 4
// 5
// 6
```

## Detailed Design

The `recursiveMap(_:)` method is declared as `Sequence` extensions, and return `RecursiveMapSequence` instance:

```swift
extension Sequence {
    public func recursiveMap<S>(
        _ transform: @escaping (Element) -> S
    ) -> RecursiveMapSequence<Self, S>
}
```

### Complexity

Calling this method is O(_1_).
