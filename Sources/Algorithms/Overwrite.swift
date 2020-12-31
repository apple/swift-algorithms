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
// overwrite(prefixUsing:), overwrite(prefixWith:), overwrite(forwardsWith:),
// overwrite(forwardsFrom:to:)
//===----------------------------------------------------------------------===//

extension MutableCollection {
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
  /// on the limiting subsequence instead.  If you need access to the elements
  /// of `source` that were not read, make an iterator from `source` and call
  /// `overwrite(prefixUsing:)` instead.
  ///
  /// - Parameters:
  ///   - source: The sequence to read the replacement values from.
  /// - Returns: The index after the last element of the overwritten prefix.  It
  ///   will be `endIndex` if every element of this collection was touched, but
  ///   `startIndex` if none were.
  /// - Postcondition: Let *k* be the element count of the shorter of `self` and
  ///   `source`.  Then `prefix(k)` will be equivalent to `source.prefix(k)`,
  ///   while `dropFirst(k)` will be unchanged.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the shorter sequence
  ///   between `self` and `source`.
  @discardableResult
  @inlinable
  public mutating func overwrite<S: Sequence>(
    prefixWith source: S
  ) -> Index where S.Element == Element {
    var iterator = source.makeIterator()
    return overwrite(prefixUsing: &iterator)
  }

  /// Copies the prefix of the given collection on top of the prefix of this
  /// collection.
  ///
  /// Copying stops when the end of the shorter collection is reached.  If you
  /// want to limit how much of this collection can be overrun, call this method
  /// on the limiting subsequence instead.
  ///
  /// - Parameters:
  ///   - source: The collection to read the replacement values from.
  /// - Returns: A two-member tuple where the first member is the past-the-end
  ///   index for the range of `source` elements that were actually read and the
  ///   second member is the past-the-end index for the range of `self` elements
  ///   that were actually overwritten.  The lower bound for each range is the
  ///   corresponding collection's `startIndex`.
  /// - Postcondition: Let *r* be the returned value from the call to this
  ///   method.  Then `self[..<r.writtenEnd]` will be equivalent to
  ///   `source[..<r.readEnd]`.  Both subsequences will have an element count of
  ///   *k*, where *k* is minimum of `count` and `source.count`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the shorter collection
  ///   between `self` and `source`.
  public mutating func overwrite<C: Collection>(
    forwardsWith source: C
  ) -> (readEnd: C.Index, writtenEnd: Index)
  where C.Element == Element {
    var indexIterator = source.indices.makeIterator()
    let end = overwrite(prefixUsing: &indexIterator) { source[$0] }
    return (indexIterator.next() ?? source.endIndex, end)
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
// overwrite(suffixUsing:), overwrite(suffixWith:), overwrite(backwardsWith:),
// overwrite(backwardsFrom:to:)
//===----------------------------------------------------------------------===//

extension MutableCollection where Self: BidirectionalCollection {
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
    return overwrite(suffixUsing: &source, doCorrect: true, { $0 })
  }

  /// Copies the prefix of the given sequence on top of the suffix of this
  /// collection.
  ///
  /// Copying stops when either the sequence is exhausted or every element of
  /// this collection is touched.  If you want to limit how much of this
  /// collection can be overrun, call this method on the limiting subsequence
  /// instead.  If you need access to the elements of `source` that were not
  /// read, make an iterator from `source` and call `overwrite(suffixUsing:)`
  /// instead.
  ///
  /// - Parameters:
  ///   - source: The sequence to read the replacement values from.
  /// - Returns: The index for the first element of the overwritten sufffix.  It
  ///   will be `startIndex` if every element of this collection was touched,
  ///   but `endIndex` if none were.
  /// - Postcondition: Let *k* be the element count of the shorter of `self` and
  ///   `source`.  Then `suffix(k)` will be equivalent to `source.prefix(k)`,
  ///   while `dropLast(k)` will be unchanged.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the shorter sequence
  ///   between `self` and `source`.
  @discardableResult
  @inlinable
  public mutating func overwrite<S: Sequence>(
    suffixWith source: S
  ) -> Index where S.Element == Element {
    var iterator = source.makeIterator()
    return overwrite(suffixUsing: &iterator)
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
  /// - Returns: A two-member tuple where the first member is the starting index
  ///   for the range of `source` elements that were actually read and the
  ///   second member is the starting index for the range of `self` elements
  ///   that were actually overwritten.  The upper bound for each range is the
  ///   corresponding collection's `endIndex`.
  /// - Postcondition: Let *r* be the returned value from the call to this
  ///   method.  Then `self[r.writtenStart...]` will be equivalent to
  ///   `source[r.readStart...]`.  Both subsequences will have an element count
  ///   of *k*, where *k* is minimum of `count` and `source.count`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the shorter collection
  ///   between `self` and `source`.
  public mutating func overwrite<C: BidirectionalCollection>(
    backwardsWith source: C
  ) -> (readStart: C.Index, writtenStart: Index)
  where C.Element == Element {
    var indexIterator = source.reversed().indices.makeIterator()
    let start = overwrite(suffixUsing: &indexIterator, doCorrect: false) {
      source[source.index(before: $0.base)]
    }
    return (indexIterator.next().map(\.base) ?? source.startIndex, start)
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

//===----------------------------------------------------------------------===//
// overwrite(prefixUsing:_:), overwrite(suffixUsing:doCorrect:_:)
//===----------------------------------------------------------------------===//

fileprivate extension MutableCollection {
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
  mutating func overwrite<I: IteratorProtocol>(
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
}

fileprivate extension MutableCollection where Self: BidirectionalCollection {
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
  ///   - doCorrect: Whether to reverse the elements after replacement so their
  ///     order maintains their orientation from `source`, or not.
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
  mutating func overwrite<I: IteratorProtocol>(
    suffixUsing source: inout I,
    doCorrect: Bool,
    _ transform: (I.Element) -> Element
  ) -> Index {
    var current = endIndex
    let start = startIndex
    while current > start, let seed = source.next() {
      formIndex(before: &current)
      self[current] = transform(seed)
    }
    if doCorrect {
      self[current...].reverse()
    }
    return current
  }
}
