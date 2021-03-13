# Breadth First Search

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/BreadthFirstSearch.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/BreadthFirstSearch.swift)]

Traverses a tree structure in breadth-first order.

This traversal can occur on any tree structure by using `BreadthFirstTreeSequence`:

```swift
let tree = Node(element: "1", children: [
	Node(element: "2", children: [
		Node(element: "5", children: [
			Node(element: "9"),
			Node(element: "10"),
		]),
		Node(element: "6"),
	]),
	Node(element: "3"),
	Node(element: "4", children: [
		Node(element: "7", children: [
			Node(element: "11"),
			Node(element: "12"),
		]),
		Node(element: "8"),
	]),
])

let elements = BreadthFirstTreeSequence(root: tree, children: { $0.children })
// Array(elements) == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
```

## Detailed Design

The `BreadthFirstTreeSequence` initializer takes two arguments:

  1. The root of the tree
  2. A closure that, given a parent node, returns all of its immediate children

`BreadthFirstTreeSequence` is a `Sequence`, which allows for use of functions like 
`first(where:)`, `contains(where:)`, `map(_:)`, and others. The `Sequence` traverses
lazily, meaning that it won’t traverse the tree further than it needs to in order to
evaluate a function. For example, `first(where:)` can return before traversing the entire
tree—an efficient breadth-first search. 

### Naming

The type’s name matches the common name of the algorithm.

### Comparison with other languages

**C++:** C++ Boost provides a `breadth_first_search` function that takes in a graph and a
starting vertex.<sup>[1](https://www.boost.org/doc/libs/1_75_0/libs/graph/doc/breadth_first_search.html)</sup>

**Rust:** petgraph offers a `Bfs` struct.<sup>[2](https://docs.rs/petgraph/0.4.10/petgraph/visit/struct.Bfs.html)</sup>
