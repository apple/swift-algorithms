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

/// A heap view of a collection's elements.

// Some to-dos:
// TODO: If the base collection is modified, the heap condition can be
//   violated. Ideally we'd notice this and recreate the heap.
// TODO: figure out if we can do better than creating an array of permutations.
// TODO: figure out if we can store the comparator closure as non-escaping.

public struct Heap<Base> where Base: Collection {
  private let base: Base

  /**
   * The permutation as an array of indices into the base collection.
   * Possibly there's a more efficient way to store them, for instance
   * only storing transpositions.
   * The heap condition holds for the elements that this array points to.
  */
  private var permutation: Array<Base.Index>

  /**
   * comparator should return true if right-hand-side should go
   * toward the root of the tree (in a max-heap, if lhs <= rhs)
   * The comparator must be escaping because we are storing it, even though
   *   under many conditions it should not have side effects or
   *   require any outside knowlege.
   */
  private let comparator: (Base.Element, Base.Element) -> Bool

  /**
   * internal init because the extension method on Collection creates a Heap.
   * postcondition: the heap condition holds on the elements that indexes points to.
   *                self.permutation.count == base.count
   * note that this depends on base.indices being a range between two indices
   *  with separation between each index of one.
   * If base.indices were implemented as a RangeSet or something like that this
   *  will not hold up.
   * The comparator closure must be @escaping so we can hold on to it.
   *   Ideally it would be good to make it side-effect free and non-escaping.
   */
  internal init(_ base: Base,
                comparator: @escaping (Base.Element, Base.Element) -> Bool) {
    self.base = base
    self.permutation = Array(base.indices)
    self.comparator = comparator
    self.collectionCount = base.count

    self.makeHeap(comparator: self.comparator)
  }

  /**
   * Swaps two entries in the array of indices
   * Returns true if swap happened
   *    otherwise false
   * Will not swap if indices out of range
   * Will not swap and will return false if indices are the same
   *
   */
  private mutating func swap(x: Array<Base.Index>.Index,
                     y: Array<Base.Index>.Index) -> Bool {
    if x != y &&
        permutation.indices.contains(x) &&
        permutation.indices.contains(y) {
      let tmp = permutation[x]
      permutation[x] = permutation[y]
      permutation[y] = tmp
      return true
    } else {
      return false
    }
  }

  /**
   * Returns translated value indirectly, through the permutation array.
   * self[0] is the root of the heap and is the max of the heap
   * The heap condition holds for the rest of the elements.
   * Note that this belongs to this heap itself.
   */
  subscript(index: Array<Base.Index>.Index) -> Base.Element? {
    get {
      if permutation.indices.contains(index) {
        let underlyingIndex = permutation[index]
        return base[underlyingIndex]
      } else {
        return .none
      }
    }
  }

  /**
   * How many items are left in the heap.
   * This is less than the number of items in the collection.
   *  zero if the heap is empty or the base collection is empty
   */
  public var count : Int {
    permutation.count
  }

  /**
   * How many items have been consumed using pop().
   */
  public var consumedCount : Int {
    base.count - permutation.count
  }

  /**
   * The base collection count
   */
  public let collectionCount : Int

  /**
   * Returns and removes the root element.
   * Returns .none if the heap is empty.
   * Maintains the heap condition by rotating elements as needed.
   * Precondition: the heap condition must hold for the elements in
   *   the base condition whose indexes are in permutation.
   * postcondition: if permutation is not empty,
   *                    permutation has one fewer element.
   *                    heap condition still applies.
   */
  mutating func pop() -> Base.Element? {
    if permutation.isEmpty {
      return .none
    }
    let result = self[0]
    let lastIndex = permutation.popLast()
    if !permutation.isEmpty, let x = lastIndex {
      permutation[0] = x
      heapThree(rootNodeIndex: 0,
                comparator: self.comparator)
    }
    return result
  }

  /**
   * Assigns root node to the max of the root and the two immediate children.
   * Calls heapThree on a child node if it's been swapped into the root to
   *   maintain the heap property on the whole sub-heap.
   * Depends on Array<Base.Index>.Index behaving like an Int with multiplication
   *   and addition, to get the child indexes
   * Preconditions: the root node index must be valid, otherwise
   *   self[rootNodeIndex]! below will fail at runtime.
   * Postcondition: The heap condition will hold for the root node and its
   *   recursive children.
   *   The permutation array may be changed.
   *   The base collection will be unchanged.
   */
  internal mutating func heapThree(rootNodeIndex: Array<Base.Index>.Index,
                                   comparator: (Base.Element, Base.Element) -> Bool) {

    let leftChildIndex = 2 * rootNodeIndex + 1
    let rightChildIndex = 2 * rootNodeIndex + 2

    let rootValue = self[rootNodeIndex]!
    let leftValueOptional = self[leftChildIndex]
    let rightValueOptional = self[rightChildIndex]

    switch (leftValueOptional, rightValueOptional) {
    case let (.some(leftValue), .some(rightValue))
          where comparator(rootValue, rightValue)
                && comparator(leftValue, rightValue):
      let _ = swap(x: rightChildIndex, y: rootNodeIndex)
      heapThree(rootNodeIndex: rightChildIndex, comparator: comparator)
    case let (.some(leftValue), .some(rightValue))
          where comparator(rootValue, leftValue)
                && comparator(rightValue, leftValue):
      let _ = swap(x: leftChildIndex, y: rootNodeIndex)
      heapThree(rootNodeIndex: leftChildIndex, comparator: comparator)
    case (.some(_), .some(_)):
      break
    case let (.some(leftValue), .none)
          where comparator(rootValue, leftValue):
      let _ = swap(x: leftChildIndex, y: rootNodeIndex)
      heapThree(rootNodeIndex: leftChildIndex, comparator: comparator)
    case (.some(_), .none):
      break
    case let (.none, .some(rightValue))
          where comparator(rootValue, rightValue):
      let _ = swap(x: rightChildIndex, y: rootNodeIndex)
      heapThree(rootNodeIndex: rightChildIndex, comparator: comparator)
    case (.none, .some(_)):
      break
    case (.none, .none) :
      break
    }
  }

  /**
   * Creates a heap for a whole collection.
   *  Starts at the last entry in the next-to-last rank of entries in
   *  the binary tree and works backward to beginning.
   */
  internal mutating func makeHeap(comparator: (Base.Element, Base.Element) -> Bool) {

    let ceilLg2 = count.bitWidth - count.leadingZeroBitCount // if this is 0, count == 0

    if ceilLg2 == 0 {
      return
    }

    let floorLg2 = ceilLg2 - 1
    // 2^(floor[lg2 n] - 1) is the index of the beginning of the last row
    // TODO: The last entries in the next-to-last row may not have
    //         children--you could also skip them at the expense of
    //         more calculation.
    let lastInternalEntry = 1 << floorLg2

    for nodeIndex in (0..<lastInternalEntry).reversed() {
      heapThree(rootNodeIndex: nodeIndex,
                comparator: comparator)
    }
  }
}
 
//===----------------------------------------------------------------------===//
// heap(comparator: @escaping (Element, Element) -> Bool) -> Heap<Self>
//===----------------------------------------------------------------------===//

extension Collection {
  public func heap(comparator: @escaping (Element, Element) -> Bool)
              -> Heap<Self> {
    return Heap(self, comparator: comparator)
  }
}
