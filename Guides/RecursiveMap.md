# RecursiveMap

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/RecursiveMap.swift) |
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/RecursiveMapTests.swift)]

## Proposed Solution

Produces a sequence containing the original sequence and the recursive mapped sequence. The order of ouput elements affects by the traversal option.

```swift
struct Node {
    var id: Int
    var children: [Node] = []
}
let tree = [
    Node(id: 1, children: [
        Node(id: 2),
        Node(id: 3, children: [
            Node(id: 4),
        ]),
        Node(id: 5),
    ]),
    Node(id: 6),
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

### Traversal Option

This function comes with two different traversal methods. This option affects the element order of the output sequence.

- `depthFirst`: The algorithm will go down first and produce the resulting path. The algorithm starts with original 
  sequence and calling the supplied closure first. This is default option.
  
  With the structure of tree:
  ```swift
  let tree = [
      Node(id: 1, children: [
          Node(id: 2),
          Node(id: 3, children: [
              Node(id: 4),
          ]),
          Node(id: 5),
      ]),
      Node(id: 6),
  ]
  ```
  
  The resulting sequence will be 1 -> 2 -> 3 -> 4 -> 5 -> 6
  
  The sequence using a buffer keep tracking the path of nodes. It should not using this option for searching the indefinite deep of tree.

- `breadthFirst`: The algorithm will go through the previous sequence first and chaining all the occurring sequences.

  With the structure of tree:
  ```swift
  let tree = [
      Node(id: 1, children: [
          Node(id: 2),
          Node(id: 3, children: [
              Node(id: 4),
          ]),
          Node(id: 5),
      ]),
      Node(id: 6),
  ]
  ```
  
  The resulting sequence will be 1 -> 6 -> 2 -> 3 -> 5 -> 4
  
  The sequence using a buffer storing occuring nodes of sequences. It should not using this option for searching the indefinite length of occuring sequences.

## Detailed Design

The `recursiveMap(option:_:)` method is declared as `Sequence` extensions, and return `RecursiveMapSequence` instance:

```swift
extension Sequence {
    public func recursiveMap<S>(
        option: RecursiveMapSequence<Self, S>.TraversalOption = .depthFirst,
        _ transform: @escaping (Element) -> S
    ) -> RecursiveMapSequence<Self, S>
}
```

### Complexity

Calling this method is O(_1_).
