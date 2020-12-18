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
// copy(from:), copy(collection:)
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
  ///   `source`.  Then `prefix(k)` will be equivalent to `source.prefix(k)`,
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

  /// Copies the elements from the given collection on top of the elements of
  /// this collection, until the shorter one is exhausted.
  ///
  /// If you want to limit how much of this collection can be overrun, call this
  /// method on the limiting subsequence instead.
  ///
  /// - Parameters:
  ///   - collection: The collection to read the replacement values from.
  /// - Returns: A two-member tuple where the first member is the index of the
  ///   first element of this collection that was not assigned a copy and the
  ///   second member is the index of the first element of `collection` that was
  ///   not used for the source of a copy.  They will be their collection's
  ///   `startIndex` if no copying was done and their collection's `endIndex` if
  ///   every element of that collection participated in a copy.
  /// - Postcondition: Let *k* be the element count of the shorter of `self` and
  ///   `collection`.  Then `prefix(k)` will be equivalent to
  ///   `collection.prefix(k)`, while `dropFirst(k)` is unchanged.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the shorter sequence
  ///   between `self` and `collection`.
  public mutating func copy<C: Collection>(
    collection: C
  ) -> (copyEnd: Index, sourceTailStart: C.Index) where C.Element == Element {
    var selfIndex = startIndex, collectionIndex = collection.startIndex
    let end = endIndex, sourceEnd = collection.endIndex
    while selfIndex < end, collectionIndex < sourceEnd {
      self[selfIndex] = collection[collectionIndex]
      formIndex(after: &selfIndex)
      collection.formIndex(after: &collectionIndex)
    }
    return (selfIndex, collectionIndex)
  }
}

//===----------------------------------------------------------------------===//
// copyOntoSuffix(with:), copyOntoSuffix(withCollection:)
//===----------------------------------------------------------------------===//

extension MutableCollection where Self: BidirectionalCollection {
  /// Copies the elements from the given sequence on top of the elements at the
  /// end of this collection, until the shorter one is exhausted.
  ///
  /// If you want to limit how much of this collection can be overrun, call this
  /// method on the limiting subsequence instead.  The elements in the mutated
  /// suffix stay in the same order as they were in `source`.
  ///
  /// - Parameters:
  ///   - source: The sequence to read the replacement values from.
  /// - Returns: A two-member tuple where the first member is the index of the
  ///   earliest element of this collection that was assigned a copy.  It will
  ///   be `endIndex` if no copying was done and `startIndex` if every element
  ///   was written over.  The second member is an iterator covering all the
  ///   elements of `source` that where not used as part of the copying.  It
  ///   will be empty if every element was used.
  /// - Postcondition: Let *k* be the element count of the shorter of `self` and
  ///   `source`.  Then `suffix(k)` will be equivalent to `source.prefix(k)`,
  ///   while `dropLast(k)` is unchanged.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the shorter sequence
  ///   between `self` and `source`.
  public mutating func copyOntoSuffix<S: Sequence>(
    with source: S
  ) -> (copyStart: Index, sourceTail: S.Iterator) where S.Element == Element {
    var current = endIndex, iterator = source.makeIterator()
    let start = startIndex
    while current > start, let source = iterator.next() {
      formIndex(before: &current)
      self[current] = source
    }
    self[current...].reverse()
    return (current, iterator)
  }

  /// Copies the elements from the given collection on top of the elements at
  /// the end of this collection, until the shorter one is exhausted.
  ///
  /// If you want to limit how much of this collection can be overrun, call this
  /// method on the limiting subsequence instead.  The elements in the mutated
  /// suffix stay in the same order as they were in `source`.
  ///
  /// - Parameters:
  ///   - source: The collection to read the replacement values from.
  /// - Returns: A two-member tuple.  The first member is the index of the
  ///   earliest element of this collection that was assigned a copy; or
  ///   `endIndex` if no copying was done.  The second member is the index
  ///   immediately after the latest element of `source` read for a copy; or
  ///   `startIndex` if no copying was done.
  /// - Postcondition: Let *k* be the element count of the shorter of `self` and
  ///   `source`.  Then `suffix(k)` will be equivalent to `source.prefix(k)`,
  ///   while `dropLast(k)` is unchanged.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the shorter sequence
  ///   between `self` and `source`.
  public mutating func copyOntoSuffix<C: Collection>(
    withCollection source: C
  ) -> (copyStart: Index, sourceTailStart: C.Index) where C.Element == Element {
    var selfIndex = endIndex, sourceIndex = source.startIndex
    let start = startIndex, sourceEnd = source.endIndex
    while selfIndex > start, sourceIndex < sourceEnd {
      formIndex(before: &selfIndex)
      self[selfIndex] = source[sourceIndex]
      source.formIndex(after: &sourceIndex)
    }
    self[selfIndex...].reverse()
    return (selfIndex, sourceIndex)
  }
}
