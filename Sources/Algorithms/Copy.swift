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
// overwrite(prefixUsing:_:), overwrite(prefixUsing:), overwrite(prefixWith:),
// overwrite(prefixWithCollection:), overwrite(forwardsFrom:to:)
//===----------------------------------------------------------------------===//

extension MutableCollection {
  /// Copies the transformed prefix of the given iterator's virtual sequence on
  /// top of the prefix of this collection, using the given closure for mapping.
  ///
  /// Copying stops when either the iterator runs out of elements or every
  /// element of this collection has been overwritten.  If you want to limit how
  /// much of this collection can be overrun, call this method on the limiting
  /// subsequence instead.
  ///
  /// - Parameters:
  ///   - source: The iterator with the virtual sequence of the seeds for the
  ///     replacement values.
  ///   - transform: The closure mapping seed values to the actual replacement
  ///     values.
  /// - Returns: The index that is one past-the-end of the elements of this
  ///   collection that were overwritten.  It will be `endIndex` if all elements
  ///   of this collection were touched, but `startIndex` if none were.
  /// - Postcondition: Let *k* be the lesser of `count` and the number of
  ///   elements in `source`'s virtual sequence.  Then `prefix(k)` will be
  ///   equivalent to the first *k* elements emitted from `source` and mapped
  ///   with `transform`, while `dropFirst(k)` is unchanged.
  ///
  /// - Complexity: O(*n*), where *n* is is the length of the shorter between
  ///   `self` and `source`'s virtual sequence.
  fileprivate mutating func overwrite<I: IteratorProtocol>(
    prefixUsing source: inout I,
    _ transform: (I.Element) -> Element
  ) -> Index {
    var current = startIndex
    let end = endIndex
    while current < end, let seed = source.next() {
      self[current] = transform(seed)
      formIndex(after: &current)
    }
    return current
  }

  /// Copies the prefix of the given iterator's virtual sequence on top of the
  /// prefix of this collection.
  ///
  /// Copying stops when either the iterator runs out of elements or every
  /// element of this collection has been overwritten.  If you want to limit how
  /// much of this collection can be overrun, call this method on the limiting
  /// subsequence instead.
  ///
  /// - Parameters:
  ///   - source: The iterator with the virtual sequence of replacement values.
  /// - Returns: The index that is one past-the-end of the elements of this
  ///   collection that were overwritten.  It will be `endIndex` if all elements
  ///   of this collection were touched, but `startIndex` if none were.
  /// - Postcondition: Let *k* be the lesser of `count` and the number of
  ///   elements in `source`'s virtual sequence.  Then the next *k* elements
  ///   from `source` will have been extracted, `prefix(k)` will be equivalent
  ///   to that extracted sequence (in emission order), and `dropFirst(k)` will
  ///   be unchanged.
  ///
  /// - Complexity: O(*n*), where *n* is is the length of the shorter between
  ///   `self` and `source`'s virtual sequence.
  @discardableResult
  public mutating func overwrite<I: IteratorProtocol>(
    prefixUsing source: inout I
  ) -> Index where I.Element == Element {
    // The second argument should be "\Element.self," but that's blocked by bug
    // SR-12897.
    return overwrite(prefixUsing: &source, { $0 })
  }

  /// Copies the prefix of the given sequence on top of the prefix of this
  /// collection.
  ///
  /// Copying stops when the end of the shorter sequence is reached.  If you
  /// want to limit how much of this collection can be overrun, call this method
  /// on the limiting subsequence instead.
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
  public mutating func overwrite<S: Sequence>(
    prefixWith source: S
  ) -> (copyEnd: Index, sourceTail: S.Iterator) where S.Element == Element {
    var current = startIndex, iterator = source.makeIterator()
    let end = endIndex
    while current < end, let source = iterator.next() {
      self[current] = source
      formIndex(after: &current)
    }
    return (current, iterator)
  }

  /// Copies the prefix of the given collection on top of the prefix of this
  /// collection.
  ///
  /// Copying stops when the end of the shorter collection is reached.  If you
  /// want to limit how much of this collection can be overrun, call this method
  /// on the limiting subsequence instead.
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
  /// - Complexity: O(*n*), where *n* is the length of the shorter collection
  ///   between `self` and `collection`.
  public mutating func overwrite<C: Collection>(
    prefixWithCollection collection: C
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

  /// Copies, in forward traversal, the prefix of a subsequence on top of the
  /// prefix of another, using the given bounds to demarcate the subsequences.
  ///
  /// Copying stops when the end of the shorter subsequence is reached.
  ///
  /// - Precondition:
  ///   - `source` and `destination` must bound valid subsequences of this collection.
  ///   - Either `source` and `destination` are disjoint, or
  ///     `self[source].startIndex >= self[destination].startIndex`.
  ///
  /// - Parameters:
  ///   - source: The index range bounding the subsequence to read the
  ///     replacement values from.
  ///   - destination: The index range bounding the subsequence whose elements
  ///     will be overwritten.
  /// - Returns: A two-member tuple where the first member are the indices of
  ///   `self[source]` that were read for copying and the second member are the
  ///   indices of `self[destination]` that were written over during copying.
  /// - Postcondition: Let *k* be the element count of the shorter of
  ///   `self[source]` and `self[destination]`, and *c* be the pre-call value of
  ///   `self[source]`.  Then `self[destination].prefix(k)` will be equivalent
  ///   to `c.prefix(k)`, while `self[destination].dropFirst(k)` is unchanged.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the shorter subsequence
  ///   between `self[source]` and `self[destination]`.
  public mutating func overwrite<R: RangeExpression, S: RangeExpression>(
    forwardsFrom source: R,
    to destination: S
  ) -> (sourceRead: Range<Index>, destinationWritten: Range<Index>)
  where R.Bound == Index, S.Bound == Index {
    let rangeS = source.relative(to: self),
        rangeD = destination.relative(to: self)
    var sourceIndex = rangeS.lowerBound, destinationIndex = rangeD.lowerBound
    while sourceIndex < rangeS.upperBound,
          destinationIndex < rangeD.upperBound {
      self[destinationIndex] = self[sourceIndex]
      formIndex(after: &sourceIndex)
      formIndex(after: &destinationIndex)
    }
    return (rangeS.lowerBound ..< sourceIndex,
            rangeD.lowerBound ..< destinationIndex)
  }
}

//===----------------------------------------------------------------------===//
// overwrite(suffixUsing:_:), overwrite(suffixUsing:), overwrite(suffixWith:),
// overwrite(suffixWithCollection:), overwrite(backwards:),
// overwrite(backwardsFrom:to:)
//===----------------------------------------------------------------------===//

extension MutableCollection where Self: BidirectionalCollection {
  /// Copies the transformed prefix of the given iterator's virtual sequence on
  /// top of the suffix of this collection, using the given closure for mapping.
  ///
  /// Copying stops when either the iterator runs out of elements or every
  /// element of this collection has been overwritten.  If you want to limit how
  /// much of this collection can be overrun, call this method on the limiting
  /// subsequence instead.
  ///
  /// - Parameters:
  ///   - source: The iterator with the virtual sequence of the seeds for the
  ///     replacement values.
  ///   - transform: The closure mapping seed values to the actual replacement
  ///     values.
  /// - Returns: The index for the first element of this collection that was
  ///   overwritten.  It will be `startIndex` if all elements of this collection
  ///   were touched, but `endIndex` if none were.
  /// - Postcondition: Let *k* be the lesser of `count` and the number of
  ///   elements in `source`'s virtual sequence.  Then `suffix(k)` will be
  ///   equivalent to the first *k* elements emitted from `source` and mapped
  ///   with `transform`, while `dropLast(k)` is unchanged.
  ///
  /// - Complexity: O(*n*), where *n* is is the length of the shorter between
  ///   `self` and `source`'s virtual sequence.
  fileprivate mutating func overwrite<I: IteratorProtocol>(
    suffixUsing source: inout I,
    _ transform: (I.Element) -> Element
  ) -> Index {
    var current = endIndex
    let start = startIndex
    while current > start, let seed = source.next() {
      formIndex(before: &current)
      self[current] = transform(seed)
    }
    self[current...].reverse()
    return current
  }

  /// Copies the prefix of the given iterator's virtual sequence on top of the
  /// suffix of this collection.
  ///
  /// Copying stops when either the iterator runs out of elements or every
  /// element of this collection has been overwritten.  If you want to limit how
  /// much of this collection can be overrun, call this method on the limiting
  /// subsequence instead.
  ///
  /// - Parameters:
  ///   - source: The iterator with the virtual sequence of replacement values.
  /// - Returns: The index for the first element of this collection that was
  ///   overwritten.  It will be `startIndex` if all elements of this collection
  ///   were touched, but `endIndex` if none were.
  /// - Postcondition: Let *k* be the lesser of `count` and the number of
  ///   elements in `source`'s virtual sequence.  Then the next *k* elements
  ///   from `source` will have been extracted, `suffix(k)` will be equivalent
  ///   to that extracted sequence (in emission order), and `dropLast(k)` will
  ///   be unchanged.
  ///
  /// - Complexity: O(*n*), where *n* is is the length of the shorter between
  ///   `self` and `source`'s virtual sequence.
  @discardableResult
  public mutating func overwrite<I: IteratorProtocol>(
    suffixUsing source: inout I
  ) -> Index where I.Element == Element {
    // The second argument should be "\Element.self," but that's blocked by bug
    // SR-12897.
    return overwrite(suffixUsing: &source, { $0 })
  }

  /// Copies the prefix of the given sequence on top of the suffix of this
  /// collection.
  ///
  /// Copying stops when either the sequence is exhausted or every element of
  /// this collection is touched.  If you want to limit how much of this
  /// collection can be overrun, call this method on the limiting subsequence
  /// instead.  The elements in the mutated suffix preserve the order they had
  /// in `source`.
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
  public mutating func overwrite<S: Sequence>(
    suffixWith source: S
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

  /// Copies the prefix of the given collection on top of the suffix of this
  /// collection.
  ///
  /// Copying stops when at least one of the collections has had all of its
  /// elements touched.  If you want to limit how much of this collection can be
  /// overrun, call this method on the limiting subsequence instead.  The
  /// elements in the mutated suffix preserve the order they had in `source`.
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
  /// - Complexity: O(*n*), where *n* is the length of the shorter collection
  ///   between `self` and `source`.
  public mutating func overwrite<C: Collection>(
    suffixWithCollection source: C
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

  /// Copies the suffix of the given collection on top of the suffix of this
  /// collection.
  ///
  /// Copying occurs backwards, and stops when the beginning of the shorter
  /// collection is reached.  If you want to limit how much of this collection
  /// can be overrun, call this method on the limiting subsequence instead.
  ///
  /// - Parameters:
  ///   - source: The collection to read the replacement values from.
  /// - Returns: A two-member tuple.  The first member is the index of the
  ///   earliest element of this collection that was assigned a copy.  The
  ///   second member is the index of the earliest element of `source` that was
  ///   read for copying.  If no copying was done, both returned indices are at
  ///   their respective owner's `endIndex`.
  /// - Postcondition: Let *k* be the element count of the shorter of `self` and
  ///   `source`.  Then `suffix(k)` will be equivalent to `source.suffix(k)`,
  ///   while `dropLast(k)` is unchanged.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the shorter collection
  ///   between `self` and `source`.
  public mutating func overwrite<C: BidirectionalCollection>(
    backwards source: C
  ) -> (writtenStart: Index, readStart: C.Index) where C.Element == Element {
    var selfIndex = endIndex, sourceIndex = source.endIndex
    let start = startIndex, sourceStart = source.startIndex
    while selfIndex > start, sourceIndex > sourceStart {
      formIndex(before: &selfIndex)
      source.formIndex(before: &sourceIndex)
      self[selfIndex] = source[sourceIndex]
    }
    return (selfIndex, sourceIndex)
  }

  /// Copies, in reverse traversal, the suffix of a subsequence on top of the
  /// suffix of another, using the given bounds to demarcate the subsequences.
  ///
  /// Copying stops when the beginning of the shorter subsequence is reached.
  ///
  /// - Precondition:
  ///   - `source` and `destination` must bound valid subsequences of this collection.
  ///   - Either `source` and `destination` are disjoint, or
  ///     `self[source].endIndex <= self[destination].endIndex`.
  ///
  /// - Parameters:
  ///   - source: The index range bounding the subsequence to read the
  ///     replacement values from.
  ///   - destination: The index range bounding the subsequence whose elements
  ///     will be overwritten.
  /// - Returns: A two-member tuple where the first member are the indices of
  ///   `self[source]` that were read for copying and the second member are the
  ///   indices of `self[destination]` that were written over during copying.
  /// - Postcondition: Let *k* be the element count of the shorter of
  ///   `self[source]` and `self[destination]`, and *c* be the pre-call value of
  ///   `self[source]`.  Then `self[destination].suffix(k)` will be equivalent
  ///   to `c.suffix(k)`, while `self[destination].dropLast(k)` is unchanged.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the shorter subsequence
  ///   between `self[source]` and `self[destination]`.
  public mutating func overwrite<R: RangeExpression, S: RangeExpression>(
    backwardsFrom source: R,
    to destination: S
  ) -> (sourceRead: Range<Index>, destinationWritten: Range<Index>)
  where R.Bound == Index, S.Bound == Index {
    let rangeS = source.relative(to: self),
        rangeD = destination.relative(to: self)
    var sourceIndex = rangeS.upperBound, destinationIndex = rangeD.upperBound
    while sourceIndex > rangeS.lowerBound,
          destinationIndex > rangeD.lowerBound {
      formIndex(before: &destinationIndex)
      formIndex(before: &sourceIndex)
      self[destinationIndex] = self[sourceIndex]
    }
    return (sourceIndex ..< rangeS.upperBound,
            destinationIndex ..< rangeD.upperBound)
  }
}
