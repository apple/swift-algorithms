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
public struct Heap<Base: Collection> where Base.Element : Comparable {
  /// The base collection.
  public let base: Base

  var indexes: [Base.Index]

  internal init(_ base: Base) {
    self.base = base
    self.indexes = Array(base.indices)
  }

  internal func doublePlusIncr(base: Base, x : Base.Index, increment: Int) -> Base.Index? {
    let lastIndex = base.index(base.endIndex, offsetBy: -1)
    let distance = base.distance(from: base.startIndex, to: x)
    if let distance2 = base.index(x,
                                  offsetBy: distance,
                                  limitedBy: lastIndex) {
      return base.index(distance2, offsetBy: increment, limitedBy: lastIndex)
    } else {
      return .none
    }

  }

  /// 2*i + 1
  public func leftChild(x : Base.Index) -> Base.Index? {
    doublePlusIncr(base: base, x: x, increment: 1)
  }

  /// 2*i + 2
  public func rightChild(x: Base.Index) -> Base.Index? {
    doublePlusIncr(base: base, x: x, increment: 2)
  }

  /// .none for the root node, otherwise (i-1) / 2
  public func parent(x: Base.Index) -> Base.Index? {
    let distance = base.distance(from: base.startIndex, to: x)
    if distance == 0 {
      return .none
    }

    let (halfDistance, _) = (distance - 1).quotientAndRemainder(dividingBy: 2)

    // if remainder == 0, left child,
    // if remainder == 1, right child

    return base.index(base.startIndex, offsetBy: halfDistance)
  }

  /* operations on array of indices */

  /// swaps two entries in the array of indices
  /// TODO: get the index type from [Base.Index]
  mutating func swap(x: Int,
                     y: Int) -> Bool {
    if indexes.indices.contains(x) && indexes.indices.contains(y) {
      let tmp = indexes[x]
      indexes[x] = indexes[y]
      indexes[y] = tmp
      return true
    } else {
      return false
    }
  }

  /**
   * Returns translated value indirectly, through the indexes array.
   * self[0] is the root of the heap and is the max of the heap
   */
  subscript(index: Int) -> Base.Element? {
    get {
      if indexes.indices.contains(index) {
        let underlyingIndex = indexes[index]
        return base[underlyingIndex]
      } else {
        return .none
      }
    }
  }

  mutating func pop() -> Base.Element? {
    if indexes.isEmpty {
      return .none
    }
    let result = self[0]
    let lastIndex = indexes.popLast()
    if !indexes.isEmpty, let x = lastIndex {
      indexes[0] = x
      heapThree(rootNodeIndex: 0)
    }
    return result
  }
  /// takes parent node in indexes array as argument.
  /// postcondition: parent node is greater than immediate chidren.

  mutating func heapThree(rootNodeIndex: Int) {

    let leftChildIndex = 2 * rootNodeIndex + 1
    let rightChildIndex = 2 * rootNodeIndex + 2

    let rootValue = self[rootNodeIndex]!
    let leftValueOptional = self[leftChildIndex]
    let rightValueOptional = self[rightChildIndex]

    switch (leftValueOptional, rightValueOptional) {
    case let (.some(leftValue), .some(rightValue)) where rootValue < rightValue && leftValue <= rightValue:
      let _ = swap(x: rightChildIndex, y: rootNodeIndex)
      heapThree(rootNodeIndex: rightChildIndex)
    case let (.some(leftValue), .some(rightValue)) where rootValue < leftValue && rightValue <= leftValue:
      let _ = swap(x: leftChildIndex, y: rootNodeIndex)
      heapThree(rootNodeIndex: leftChildIndex)
        //swap root, left
    case (.some(_), .some(_)):
      // rootvalue > right and left values
      break
    case let (.some(leftValue), .none) where rootValue < leftValue:
      let _ = swap(x: leftChildIndex, y: rootNodeIndex)
      heapThree(rootNodeIndex: leftChildIndex)
    case (.some(_), .none):
      // rootvalue > leftValue
      break
    case let (.none, .some(rightValue)) where rootValue < rightValue:
      let _ = swap(x: rightChildIndex, y: rootNodeIndex)
      heapThree(rootNodeIndex: rightChildIndex)
        //swap root, right
    case (.none, .some(_)):
      //rootvalue > rightValue
      break
    case (.none, .none) :
      // rootvalue is only value
      break
    }
    //    orders: root  < left  < right -> swap root, right
    //          : left  < root  < right -> swap root, right
    //          : root  < right < left  -> swap root, left
    //          : right < root  < left  -> swap root, left
    //          : right < left  < root  -> no swap
    //          : left  < right < root  -> no swap
    //  .none < everything
    //  equal values go left < right < root

  }

  func isHeapThree(rootNodeIndex: Int) -> Bool {
    let leftChildIndex = 2 * rootNodeIndex + 1
    let rightChildIndex = 2 * rootNodeIndex + 2

    let rootValue = self[rootNodeIndex]!
    let leftValueOptional = self[leftChildIndex]
    let rightValueOptional = self[rightChildIndex]

    switch (leftValueOptional, rightValueOptional) {
    case let (.some(leftValue), .some(rightValue)):
      return leftValue <= rootValue && rightValue <= rootValue
    case let (.some(leftValue), .none):
      return leftValue <= rootValue
    case let (.none, .some(rightValue)):
      return rightValue <= rootValue
    case (.none, .none):
      return true
    }
  }

  func isHeapThreeAll() -> Bool {
    var result: Bool = true
    for nodeIndex in indexes.indices.reversed() {
      let thisResult = isHeapThree(rootNodeIndex: nodeIndex)
      assert(thisResult)
      result = result && thisResult
    }
    return result
//    indexes.indices.reversed().allSatisfy {isHeapThree(rootNodeIndex:$0)}
  }
  
  /// starts at last entry in last inner node
  /// calls heapThree on each
  /// works backward to beginning of array
  mutating func makeHeap() {
    for nodeIndex in indexes.indices.reversed() {
      heapThree(rootNodeIndex: nodeIndex)
    }
  }
}
 
//===----------------------------------------------------------------------===//
// heap()
//===----------------------------------------------------------------------===//

extension Collection {
  public func heap() -> Heap<Self> where Self: Comparable {
    return Heap(self)
  }
}
