//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020-2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// stablePartition(by:)
//===----------------------------------------------------------------------===//

extension MutableCollection {
  /// Moves all elements satisfying `belongsInSecondPartition` into a suffix of
  /// the collection, preserving their relative order, and returns the start of
  /// the resulting suffix.
  ///
  /// - Complexity: O(*n* log *n*), where *n* is the number of elements.
  /// - Precondition:
  ///   `n == distance(from: range.lowerBound, to: range.upperBound)`
  @inlinable
  internal mutating func stablePartition(
    count n: Int,
    subrange: Range<Index>,
    by belongsInSecondPartition: (Element) throws -> Bool
  ) rethrows -> Index {
    if n == 0 { return subrange.lowerBound }
    if n == 1 {
      return try belongsInSecondPartition(self[subrange.lowerBound])
        ? subrange.lowerBound
        : subrange.upperBound
    }
    
    let h = n / 2, i = index(subrange.lowerBound, offsetBy: h)
    let j = try stablePartition(
      count: h,
      subrange: subrange.lowerBound..<i,
      by: belongsInSecondPartition)
    let k = try stablePartition(
      count: n - h,
      subrange: i..<subrange.upperBound,
      by: belongsInSecondPartition)
    return rotate(subrange: j..<k, toStartAt: i)
  }
  
  /// Moves all elements satisfying the given predicate into a suffix of the
  /// given range, preserving the relative order of the elements in both
  /// partitions, and returns the start of the resulting suffix.
  ///
  /// - Parameters:
  ///   - subrange: The range of elements within this collection to partition.
  ///   - belongsInSecondPartition: A predicate used to partition the
  ///     collection. All elements satisfying this predicate are ordered after
  ///     all elements not satisfying it.
  ///
  /// - Complexity: O(*n* log *n*), where *n* is the length of this collection.
  @inlinable
  public mutating func stablePartition(
    subrange: Range<Index>,
    by belongsInSecondPartition: (Element) throws-> Bool
  ) rethrows -> Index {
    try stablePartition(
      count: distance(from: subrange.lowerBound, to: subrange.upperBound),
      subrange: subrange,
      by: belongsInSecondPartition)
  }
  
  /// Moves all elements satisfying the given predicate into a suffix of this
  /// collection, preserving the relative order of the elements in both
  /// partitions, and returns the start of the resulting suffix.
  ///
  /// - Parameter belongsInSecondPartition: A predicate used to partition the
  ///   collection. All elements satisfying this predicate are ordered after
  ///   all elements not satisfying it.
  ///
  /// - Complexity: O(*n* log *n*), where *n* is the length of this collection.
  @inlinable
  public mutating func stablePartition(
    by belongsInSecondPartition: (Element) throws-> Bool
  ) rethrows -> Index {
    try stablePartition(
      subrange: startIndex..<endIndex,
      by: belongsInSecondPartition)
  }
}

//===----------------------------------------------------------------------===//
// partition(by:)
//===----------------------------------------------------------------------===//

extension MutableCollection {
  /// Moves all elements satisfying `isSuffixElement` into a suffix of the
  /// collection, returning the start position of the resulting suffix.
  ///
  /// - Complexity: O(*n*) where n is the length of the collection.
  @inlinable
  public mutating func partition(
    subrange: Range<Index>,
    by belongsInSecondPartition: (Element) throws -> Bool
  ) rethrows -> Index {
    // This version of `partition(subrange:)` is half stable; the elements in
    // the first partition retain their original relative order.
    guard var i = try self[subrange].firstIndex(where: belongsInSecondPartition)
      else { return subrange.upperBound }
    
    var j = index(after: i)
    while j != subrange.upperBound {
      if try !belongsInSecondPartition(self[j]) {
        swapAt(i, j)
        formIndex(after: &i)
      }
      formIndex(after: &j)
    }
    
    return i
  }
}

extension MutableCollection where Self: BidirectionalCollection {
  /// Moves all elements satisfying `isSuffixElement` into a suffix of the
  /// collection, returning the start position of the resulting suffix.
  ///
  /// - Complexity: O(*n*) where n is the length of the collection.
  @inlinable
  public mutating func partition(
    subrange: Range<Index>,
    by belongsInSecondPartition: (Element) throws -> Bool
  ) rethrows -> Index {
    var lo = subrange.lowerBound
    var hi = subrange.upperBound

    // 'Loop' invariants (at start of Loop, all are true):
    // * lo < hi
    // * predicate(self[i]) == false, for i in startIndex ..< lo
    // * predicate(self[i]) == true, for i in hi ..< endIndex

    Loop: while true {
      FindLo: do {
        while lo < hi {
          if try belongsInSecondPartition(self[lo]) { break FindLo }
          formIndex(after: &lo)
        }
        break Loop
      }

      FindHi: do {
        formIndex(before: &hi)
        while lo < hi {
          if try !belongsInSecondPartition(self[hi]) { break FindHi }
          formIndex(before: &hi)
        }
        break Loop
      }

      swapAt(lo, hi)
      formIndex(after: &lo)
    }

    return lo
  }
}

//===----------------------------------------------------------------------===//
// partitioningIndex(where:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns the start index of the partition of a collection that matches
  /// the given predicate.
  ///
  /// The collection must already be partitioned according to the predicate.
  /// That is, there should be an index `i` where for every element in
  /// `collection[..<i]` the predicate is `false`, and for every element in
  /// `collection[i...]` the predicate is `true`.
  ///
  /// - Parameter belongsInSecondPartition: A predicate that partitions the
  ///   collection.
  /// - Returns: The index of the first element in the collection for which
  ///   `predicate` returns `true`, or `endIndex` if there are no elements
  ///   for which `predicate` returns `true`.
  ///
  /// - Complexity: O(log *n*), where *n* is the length of this collection if
  ///   the collection conforms to `RandomAccessCollection`, otherwise O(*n*).
  @inlinable
  public func partitioningIndex(
    where belongsInSecondPartition: (Element) throws -> Bool
  ) rethrows -> Index {
    var n = count
    var l = startIndex
    
    while n > 0 {
      let half = n / 2
      let mid = index(l, offsetBy: half)
      if try belongsInSecondPartition(self[mid]) {
        n = half
      } else {
        l = index(after: mid)
        n -= half + 1
      }
    }
    return l
  }
}

//===----------------------------------------------------------------------===//
// partitioned(by:)
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Returns two arrays containing the elements of the sequence that
  /// don’t and do satisfy the given predicate, respectively.
  ///
  /// In this example, `partitioned(by:)` is used to separate the input based on
  /// whether a name is shorter than five characters:
  ///
  ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
  ///     let (longNames, shortNames) = cast.partitioned(by: { $0.count < 5 })
  ///     print(longNames)
  ///     // Prints "["Vivien", "Marlon"]"
  ///     print(shortNames)
  ///     // Prints "["Kim", "Karl"]"
  ///
  /// - Parameter predicate: A closure that takes an element of the sequence as
  /// its argument and returns a Boolean value indicating whether the element
  /// should be included in the second returned array. Otherwise, the element
  /// will appear in the first returned array.
  ///
  /// - Returns: Two arrays with all of the elements of the receiver. The
  /// first array contains all the elements that `predicate` didn’t allow, and
  /// the second array contains all the elements that `predicate` allowed. The
  /// order of the elements in the arrays matches the order of the elements in
  /// the original sequence.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func partitioned(
    by predicate: (Element) throws -> Bool
  ) rethrows -> (falseElements: [Element], trueElements: [Element]) {
    var lhs = [Element]()
    var rhs = [Element]()
    
    for element in self {
      if try predicate(element) {
        rhs.append(element)
      } else {
        lhs.append(element)
      }
    }
    
    return (lhs, rhs)
  }
}

extension Collection {
  /// Returns two arrays containing the elements of the collection that
  /// don’t and do satisfy the given predicate, respectively.
  ///
  /// In this example, `partitioned(by:)` is used to separate the input based on
  /// whether a name is shorter than five characters.
  ///
  ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
  ///     let (longNames, shortNames) = cast.partitioned(by: { $0.count < 5 })
  ///     print(longNames)
  ///     // Prints "["Vivien", "Marlon"]"
  ///     print(shortNames)
  ///     // Prints "["Kim", "Karl"]"
  ///
  /// - Parameter predicate: A closure that takes an element of the collection
  /// as its argument and returns a Boolean value indicating whether the element
  /// should be included in the second returned array. Otherwise, the element
  /// will appear in the first returned array.
  ///
  /// - Returns: Two arrays with all of the elements of the receiver. The
  /// first array contains all the elements that `predicate` didn’t allow, and
  /// the second array contains all the elements that `predicate` allowed. The
  /// order of the elements in the arrays matches the order of the elements in
  /// the original collection.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func partitioned(
    by predicate: (Element) throws -> Bool
  ) rethrows -> (falseElements: [Element], trueElements: [Element]) {
    guard !self.isEmpty else {
      return ([], [])
    }
    
    // Since collections have known sizes, we can allocate one array of size
    // `self.count`, then insert items at the beginning or end of that contiguous
    // block. This way, we don’t have to do any dynamic array resizing. Since we
    // insert the right elements on the right side in reverse order, we need to
    // reverse them back to the original order at the end.
    
    let count = self.count
    
    // Inside of the `initializer` closure, we set what the actual mid-point is.
    // We will use this to partition the single array into two.
    var midPoint: Int = 0
    
    let elements = try [Element](
      unsafeUninitializedCapacity: count,
      initializingWith: { buffer, initializedCount in
        var lhs = buffer.baseAddress!
        var rhs = lhs + buffer.count
        do {
          for element in self {
            if try predicate(element) {
              rhs -= 1
              rhs.initialize(to: element)
            } else {
              lhs.initialize(to: element)
              lhs += 1
            }
          }
          
          precondition(lhs == rhs, """
            Collection's `count` differed from the number of elements iterated.
            """
          )
          
          let rhsIndex = rhs - buffer.baseAddress!
          buffer[rhsIndex...].reverse()
          initializedCount = buffer.count
          
          midPoint = rhsIndex
        } catch {
          let lhsCount = lhs - buffer.baseAddress!
          let rhsCount = (buffer.baseAddress! + buffer.count) - rhs
          buffer.baseAddress!.deinitialize(count: lhsCount)
          rhs.deinitialize(count: rhsCount)
          throw error
        }
      })
    
    let lhs = elements[..<midPoint]
    let rhs = elements[midPoint...]
    return (
      Array(lhs),
      Array(rhs)
    )
  }
}
