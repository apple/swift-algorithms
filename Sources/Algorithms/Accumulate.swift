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

//===----------------------------------------------------------------------===//
// accumulate(via:), disperse(via:)
//===----------------------------------------------------------------------===//

extension MutableCollection {
  /// Progressively replaces each element with the combination of its
  /// (post-mutation) predecessor and itself, using the given closure to
  /// generate the new values.
  ///
  /// For each pair of adjacent elements, the former is fed as the first
  /// argument to the closure and the latter is fed as the second.  Iteration
  /// goes from the second element to the last.
  ///
  /// - Parameters:
  ///   - combine: The closure that fuses two values to a new one.
  /// - Postcondition: `dropFirst()` is replaced by
  ///   `dropFirst().scan(first!, combine)`.  There is no effect if the
  ///   collection has fewer than two elements.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  public mutating func accumulate(
    via combine: (Element, Element) throws -> Element
  ) rethrows {
    let end = endIndex
    var previous = startIndex
    guard previous < end else { return }

    var current = index(after: previous)
    while current < end {
      self[current] = try combine(self[previous], self[current])
      previous = current
      formIndex(after: &current)
    }
  }

  /// Progressively replaces each element with the disassociation between its
  /// (pre-mutation) predecessor and itself, using the given closure to generate
  /// the new values.
  ///
  /// For each pair of adjacent elements, the former is fed as the second
  /// argument to the closure and the latter is fed as the first.  Iteration
  /// goes from the second element to the last.
  ///
  /// - Parameters:
  ///   - sever: The closure that defuses a value out of another.
  /// - Postcondition: Define `combine` as the counter-operation to `sever`,
  ///   such that `combine(sever(c, b), b)` is equivalent to `c`.  Then calling
  ///   `accumulate(via: combine)` after running this method will set `self` to
  ///   a state equivalent to what it was before running this method.  There is
  ///   no effect if the collection has fewer than two elements.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  public mutating func disperse(
    via sever: (Element, Element) throws -> Element
  ) rethrows {
    guard var previousValue = first else { return }

    let end = endIndex
    var currentIndex = index(after: startIndex)
    while currentIndex < end {
      let currentValue = self[currentIndex]
      self[currentIndex] = try sever(currentValue, previousValue)
      previousValue = currentValue
      formIndex(after: &currentIndex)
    }
  }
}
