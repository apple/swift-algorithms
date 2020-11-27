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
// copy(from:)
//===----------------------------------------------------------------------===//

extension MutableCollection {
  /// Copies the elements from the given sequence on top of the elements of this
  /// collection, until the shorter one is exhausted.
  ///
  /// If you want to limit how much of this collection can be overrun, call this
  /// method on the limiting subsequence instead.
  ///
  /// - Parameters:
  ///   - source: The sequence to read the replacement values from.
  /// - Returns: A two-member tuple where the first member is the index of the
  ///   first element of this collection that was not assigned a copy.  It will
  ///   be `startIndex` if no copying was done and `endIndex` if every element
  ///   was written over.  The second member is an iterator covering all the
  ///   elements of `source` that where not used as part of the copying.  It
  ///   will be empty if every element was used.
  /// - Postcondition: Let *k* be the element count of the shorter of `self` and
  ///   source.  Then `prefix(k)` will be equivalent to `source.prefix(k)`,
  ///   while `dropFirst(k)` is unchanged.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the shorter sequence
  ///   between `self` and `source`.
  public mutating func copy<S: Sequence>(
    from source: S
  ) -> (copyEnd: Index, sourceTail: S.Iterator) where S.Element == Element {
    var current = startIndex, iterator = source.makeIterator()
    let end = endIndex
    while current < end, let source = iterator.next() {
      self[current] = source
      formIndex(after: &current)
    }
    return (current, iterator)
  }
}
