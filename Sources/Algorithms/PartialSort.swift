//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Returns the elements of the sequence such that the 0...k range contains
  /// the first k sorted elements in this sequence, using the given predicate
  /// as the comparison between elements.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// smallest values:
  ///
  ///     let numbers = [7,1,6,2,8,3,9]
  ///     let almostSorted = numbers.partiallySorted(3, <)
  ///     // [1, 2, 3, 9, 7, 6, 8]
  ///     let smallestThree = almostSorted.prefix(3)
  ///     // [1, 2, 3]
  ///
  /// The order of equal elements is not guaranteed to be preserved, and the
  /// order of the remaining elements is unspecified.
  ///
  /// If you need to sort a sequence but only need access to a prefix of its
  /// elements, using this method can give you a performance boost over sorting
  ///  the entire sequence.
  ///
  /// - Parameter count: The k number of elements to partially sort.
  /// - Parameter areInIncreasingOrder: A predicate that returns true if its
  /// first argument should be ordered before its second argument;
  ///  otherwise, false.
  ///
  /// - Complexity: O(k log n)
  public func partiallySorted(
    _ count: Int,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [Element] {
    var result = ContiguousArray(self)
    try result.partiallySort(count, by: areInIncreasingOrder)
    return Array(result)
  }
}

extension Sequence where Element: Comparable {
  /// Returns the elements of the sequence such that the 0...k range contains
  /// the first k smallest elements in this sequence.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// smallest values:
  ///
  ///     let numbers = [7,1,6,2,8,3,9]
  ///     let almostSorted = numbers.partiallySorted(3)
  ///     // [1, 2, 3, 9, 7, 6, 8]
  ///     let smallestThree = almostSorted.prefix(3)
  ///     // [1, 2, 3]
  ///
  /// The order of equal elements is not guaranteed to be preserved, and the
  /// order of the remaining elements is unspecified.
  ///
  /// If you need to sort a sequence but only need access to a prefix of
  /// its elements, using this method can give you a performance boost over
  ///  sorting the entire sequence.
  ///
  /// - Parameter count: The k number of elements to partially sort
  /// in ascending order.
  ///
  /// - Complexity: O(k log n)
  public func partiallySorted(_ count: Int) -> [Element] {
    return partiallySorted(count, by: <)
  }
}

extension MutableCollection where Self: RandomAccessCollection {
  /// Rearranges this collection such that the 0...k range contains the first
  /// k sorted elements in this collection, using the given predicate as the
  /// comparison between elements.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// smallest values:
  ///
  ///     var numbers = [7,1,6,2,8,3,9]
  ///     numbers.partiallySort(3, <)
  ///     // [1, 2, 3, 9, 7, 6, 8]
  ///     let smallestThree = numbers.prefix(3)
  ///     // [1, 2, 3]
  ///
  /// The order of equal elements is not guaranteed to be preserved, and the
  /// order of the remaining elements is unspecified.
  ///
  /// If you need to sort a collection but only need access to a prefix of its
  /// elements, using this method can give you a performance boost over sorting
  /// the entire collection.
  ///
  /// - Parameter count: The k number of elements to partially sort.
  /// - Parameter areInIncreasingOrder: A predicate that returns true if its
  /// first argument should be ordered before its second argument;
  /// otherwise, false.
  ///
  /// - Complexity: O(k log n)
  public mutating func partiallySort(
    _ count: Int,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    try __partiallySort(count, by: areInIncreasingOrder)
  }
}

extension MutableCollection
where Self: RandomAccessCollection, Element: Comparable {
  /// Rearranges this collection such that the 0...k range contains the first
  /// k smallest elements in this collection.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// smallest values:
  ///
  ///     var numbers = [7,1,6,2,8,3,9]
  ///     numbers.partiallySort(3)
  ///     // [1, 2, 3, 9, 7, 6, 8]
  ///     let smallestThree = numbers.prefix(3)
  ///     // [1, 2, 3]
  ///
  /// The order of equal elements is not guaranteed to be preserved, and the
  /// order of the remaining elements is unspecified.
  ///
  /// If you need to sort a collection but only need access to a prefix of its
  /// elements, using this method can give you a performance boost over sorting
  /// the entire collection.
  ///
  /// - Parameter count: The k number of elements to partially sort
  /// in ascending order.
  ///
  /// - Complexity: O(k log n)
  public mutating func partiallySort(_ count: Int) {
    partiallySort(count, by: <)
  }
}

//===----------------------------------------------------------------------===//
// __partiallySort(_:by:)
//===----------------------------------------------------------------------===//

extension MutableCollection where Self: RandomAccessCollection {
  typealias Priority = (Element, Element) throws -> Bool

  /// Partially sorts this collection by using an in place heapsort that stops
  /// after we find the desired k amount
  /// of elements. The heap is stored and processed in reverse order so that
  ///  the collection doesn't have to be flipped once the final result is found.
  ///
  /// Complexity: O(k log n)
  mutating func __partiallySort(
    _ k: Int,
    by areInIncreasingOrder: Priority
  ) rethrows {
    assert(k >= 0, """
      Cannot partially sort with a negative amount of elements!
      """
    )

    assert(k <= count, """
      Cannot partially sort more than this Sequence's size!
      """
    )

    guard k > 0 else {
      return
    }
    guard isEmpty == false else {
      return
    }
    var heapEndIndex = 0
    for i in ((count / 2) + 1)..<count {
      try siftDown(i, by: areInIncreasingOrder, heapEndIndex: heapEndIndex)
    }
    var iterator = (0..<k).makeIterator()
    _ = iterator.next()
    swapAt(index(before: endIndex), index(startIndex, offsetBy: heapEndIndex))
    heapEndIndex += 1
    while let _ = iterator.next() {
      try siftDown(
        count - 1,
        by: areInIncreasingOrder,
        heapEndIndex: heapEndIndex
      )
      swapAt(index(before: endIndex), index(startIndex, offsetBy: heapEndIndex))
      heapEndIndex += 1
    }
  }

  /// Sifts down an element from this heap.
  /// The heap is stored in reverse order, so sifting down will actually
  /// move the element up in the heap.
  ///
  /// - Parameter i: The element index to sift down
  /// - Parameter by: The predicate to use when determining the priority
  /// of elements in the heap
  /// - Parameter heapEndIndex: The index in reverse order, where the heap ends.
  private mutating func siftDown(
    _ i: Int,
    by priority: Priority,
    heapEndIndex: Int
  ) rethrows {
    let indexToSwap = try highestPriorityIndex(
      of: i,
      by: priority,
      heapEndIndex: heapEndIndex
    )
    guard indexToSwap != i else {
      return
    }
    swapAt(
      index(startIndex, offsetBy: i),
      index(startIndex, offsetBy: indexToSwap)
    )
    try siftDown(indexToSwap, by: priority, heapEndIndex: heapEndIndex)
  }

  private func highestPriorityIndex(
    of index: Int,
    by priority: Priority,
    heapEndIndex: Int
  ) rethrows -> Int {
    let reverseHeapTrueIndex = self.count - 1 - index
    let leftChildDistance =
      leftChildIndex(of: reverseHeapTrueIndex) - reverseHeapTrueIndex
    let leftChild = index - leftChildDistance

    let rightChildDistance =
      rightChildIndex(of: reverseHeapTrueIndex) - reverseHeapTrueIndex
    let rightChild = index - rightChildDistance

    let left = try highestPriorityIndex(
      of: index,
      and: leftChild,
      by: priority,
      heapEndIndex: heapEndIndex
    )

    let right = try highestPriorityIndex(
      of: index,
      and: rightChild,
      by: priority,
      heapEndIndex: heapEndIndex
    )
    return try highestPriorityIndex(
      of: left,
      and: right,
      by: priority,
      heapEndIndex: heapEndIndex
    )
  }

  private func leftChildIndex(of index: Int) -> Int {
    return (2 * index) + 1
  }

  private func rightChildIndex(of index: Int) -> Int {
    return (2 * index) + 2
  }

  private func highestPriorityIndex(
    of parent: Int,
    and child: Int,
    by priority: Priority,
    heapEndIndex: Int
  ) rethrows -> Int {
    guard child >= heapEndIndex else {
      return parent
    }
    let childElement = self[index(startIndex, offsetBy: child)]
    let parentElement = self[index(startIndex, offsetBy: parent)]
    guard try priority(childElement, parentElement) else {
      return parent
    }
    return child
  }
}
