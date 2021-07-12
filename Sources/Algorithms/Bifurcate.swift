//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Returns two arrays containing, in order, the elements of the sequence that
  /// do and don’t satisfy the given predicate, respectively.
  ///
  /// In this example, `bifurcate()` is used to include only
  /// names shorter than five characters:
  ///
  ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
  ///     let (shortNames, longNames) = cast.bifurcate({ $0.count < 5 })
  ///     print(shortNames)
  ///     // Prints "["Kim", "Karl"]"
  ///     print(longNames)
  ///     // Prints "["Vivien", "Marlon"]"
  ///
  /// - Parameter belongsInFirstCollection: A closure that takes an element of
  /// the sequence as its argument and returns a Boolean value indicating
  /// whether the element should be included in the first returned array.
  /// Otherwise, the element will appear in the second returned array.
  ///
  /// - Returns: Two arrays with with all of the elements of the receiver. The
  /// first array contains all the elements that `belongsInFirstCollection`
  /// allowed, and the second array contains all the elements that
  /// `belongsInFirstCollection` didn’t allow.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  ///
  /// - Note: This algorithm performs a bit slower than the same algorithm on
  /// `RandomAccessCollection` since the size of the sequence is unknown, unlike
  /// `RandomAccessCollection`.
  @inlinable
  public func bifurcate(
    _ belongsInFirstCollection: (Element) throws -> Bool
  ) rethrows -> ([Element], [Element]) {
    var lhs = ContiguousArray<Element>()
    var rhs = ContiguousArray<Element>()
    
    for element in self {
      if try belongsInFirstCollection(element) {
        lhs.append(element)
      } else {
        rhs.append(element)
      }
    }
    
    return _tupleMap((lhs, rhs), { Array($0) })
  }
}

extension Collection {
  // This is a specialized version of the same algorithm on `Sequence` that
  // avoids reallocation of arrays since `count` is known ahead of time.
  @inlinable
  public func bifurcate(
    _ belongsInFirstCollection: (Element) throws -> Bool
  ) rethrows -> ([Element], [Element]) {
    guard !self.isEmpty else {
      return ([], [])
    }
    
    // Since `RandomAccessCollection`s have known sizes (access to `count` is
    // constant time, O(1)), we can allocate one array of size `self.count`,
    // then insert items at the beginning or end of that contiguous block. This
    // way, we don’t have to do any dynamic array resizing. Since we insert the
    // right elements on the right side in reverse order, we need to reverse
    // them back to the original order at the end.
    
    let count = self.count
    
    // Inside of the `initializer` closure, we set what the actual mid-point is.
    // We will use this to bifurcate the single array into two in constant time.
    var midPoint: Int = 0
    
    let elements = try [Element](
      unsafeUninitializedCapacity: count,
      initializingWith: { buffer, initializedCount in
      var lhs = buffer.baseAddress!
      var rhs = lhs + buffer.count
      do {
        for element in self {
          if try belongsInFirstCollection(element) {
            lhs.initialize(to: element)
            lhs += 1
          } else {
            rhs -= 1
            rhs.initialize(to: element)
          }
        }
        
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
    
    let collections = elements.bifurcate(upTo: midPoint)
    return _tupleMap(collections, { Array($0) })
  }
}

extension Collection {
  /// Splits the receiving collection into two at the specified index
  /// - Parameter index: The index within the receiver to split the collection
  /// - Returns: A tuple with the first and second parts of the receiving
  /// collection after splitting it
  /// - Note: The first subsequence in the returned tuple does *not* include
  /// the element at `index`. That element is in the second subsequence.
  /// - Complexity: O(*1*)
  @inlinable
  public func bifurcate(upTo index: Index) -> (SubSequence, SubSequence) {
    return (
      self[self.startIndex..<index],
      self[index..<self.endIndex]
    )
  }
}

/// Returns a tuple containing the results of mapping the given closure over
/// each of the tuple’s elements.
/// - Parameters:
///   - x: The tuple to transform
///   - transform: A mapping closure. `transform` accepts an element of this
///   sequence as its parameter and returns a transformed
/// - Returns: A tuple containing the transformed elements of this tuple.
@usableFromInline
internal func _tupleMap<T, U>(
  _ x: (T, T),
  _ transform: (T) throws -> U
) rethrows -> (U, U) {
  return (
    try transform(x.0),
    try transform(x.1)
  )
}
