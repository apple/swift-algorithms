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

//===----------------------------------------------------------------------===//
// contains(_:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns a Boolean value indicating whether this collection at any position
  /// contains the same elements as another collection in the same order,
  /// according to the given equivalence function.
  ///
  ///     let string = "foo, bar"
  ///     print(string.contains("foo, ", by: ==)) // true
  ///     print(string.contains("bar, ", by: ==)) // false
  ///
  /// - Parameters:
  ///   - other: The collection to search for.
  ///   - areEquivalent: A predicate that returns true if its two arguments are
  ///     equivalent; otherwise, false.
  /// - Returns: `true` if there exists an index range `r` such that `self[r]`
  ///   equals `other` according to `areEquivalent`.
  ///
  /// - Complexity: O(*n \* m*), where *n* is the length of this collection
  ///   and *m* is the length of the collection being searched for.
  @inlinable
  public func contains<Other: Collection>(
    _ other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> Bool {
    try firstRange(of: other, by: areEquivalent) != nil
  }
}

extension Collection where Element: Equatable {
  /// Returns a Boolean value indicating whether this collection at any position
  /// contains the same elements as another collection in the same order.
  ///
  ///     let string = "foo, bar"
  ///     print(string.contains("foo, ")) // true
  ///     print(string.contains("bar, ")) // false
  ///
  /// - Parameter other: The collection to search for.
  /// - Returns: `true` if there exists an index range `r` such that `self[r]`
  ///   equals `other`.
  ///
  /// - Complexity: O(*n \* m*), where *n* is the length of this collection
  ///   and *m* is the length of the collection being searched for.
  @inlinable
  public func contains<Other: Collection>(
    _ other: Other
  ) -> Bool where Other.Element == Element {
    contains(other, by: ==)
  }
}

//===----------------------------------------------------------------------===//
// firstRange(of:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns the first index range where this collection contains the same
  /// elements as another collection in the same order, according to the given
  /// equivalence function.
  ///
  ///     let string = "foo, bar, foo, bar"
  ///     if let range = string.firstRange(of: "bar", by: ==) {
  ///         print(string[..<range.lowerBound]) // "foo, "
  ///         print(string[range])               // "bar"
  ///         print(string[range.upperBound...]) // ", foo, bar"
  ///     }
  ///
  /// - Parameters:
  ///   - other: The collection to search for.
  ///   - areEquivalent: A predicate that returns true if its two arguments are
  ///     equivalent; otherwise, false.
  /// - Returns: The first index range `r` such that `self[r]` equals `other`
  ///   according to `areEquivalent`.
  ///
  /// - Complexity: O(*n \* m*), where *n* is the length of this collection
  ///   and *m* is the length of the collection being searched for.
  @inlinable
  public func firstRange<Other: Collection>(
    of other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> Range<Index>? {
    var searchStart = startIndex
    
    guard let needleFirst = other.first else {
      return searchStart..<searchStart
    }

    while let matchStart = try self[searchStart...]
            .firstIndex(where: { try areEquivalent($0, needleFirst) })
    {
      var index = matchStart
      var otherIndex = other.startIndex

      repeat {
        formIndex(after: &index)
        other.formIndex(after: &otherIndex)
        
        if otherIndex == other.endIndex {
          return matchStart..<index
        } else if index == endIndex {
          return nil
        }
      } while try areEquivalent(self[index], other[otherIndex])

      searchStart = self.index(after: matchStart)
    }

    return nil
  }
}

extension Collection where Element: Equatable {
  /// Returns the first index range where this collection contains the same
  /// elements as another collection in the same order.
  ///
  ///     let string = "foo, bar, foo, bar"
  ///     if let range = string.firstRange(of: "bar") {
  ///         print(string[..<range.lowerBound]) // "foo, "
  ///         print(string[range])               // "bar"
  ///         print(string[range.upperBound...]) // ", foo, bar"
  ///     }
  ///
  /// - Parameter other: The collection to search for.
  /// - Returns: The first index range `r` such that `self[r]` equals `other`.
  ///
  /// - Complexity: O(*n \* m*), where *n* is the length of this collection
  ///   and *m* is the length of the collection being searched for.
  @inlinable
  public func firstRange<Other: Collection>(of other: Other) -> Range<Index>?
    where Other.Element == Element
  {
    firstRange(of: other, by: ==)
  }
}

//===----------------------------------------------------------------------===//
// lastRange(of:)
//===----------------------------------------------------------------------===//

extension BidirectionalCollection {
  /// Returns the last index range where this collection contains the same
  /// elements as another collection in the same order, according to the given
  /// equivalence function.
  ///
  ///     let string = "foo, bar, foo, bar"
  ///     if let range = string.lastRange(of: "foo", by: ==) {
  ///         print(string[..<range.lowerBound]) // "foo, bar, "
  ///         print(string[range])               // "foo"
  ///         print(string[range.upperBound...]) // ", bar"
  ///     }
  ///
  /// - Parameters:
  ///   - other: The collection to search for.
  ///   - areEquivalent: A predicate that returns true if its two arguments are
  ///     equivalent; otherwise, false.
  /// - Returns: The last index range `r` such that `self[r]` equals `other`
  ///   according to `areEquivalent`.
  ///
  /// - Complexity: O(*n \* m*), where *n* is the length of this collection
  ///   and *m* is the length of the collection being searched for.
  @inlinable
  public func lastRange<Other: BidirectionalCollection>(
    of other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> Range<Index>? {
    var searchEnd = endIndex
    
    guard let otherLastIndex = other.indices.last else {
      return searchEnd..<searchEnd
    }
    
    let needleLast = other[otherLastIndex]
    
    let startIndex = startIndex
    let otherStartIndex = other.startIndex

    while let matchEnd = try self[..<searchEnd]
            .lastIndex(where: { try areEquivalent($0, needleLast) })
    {
      var index = matchEnd
      var otherIndex = otherLastIndex

      repeat {
        if otherIndex == otherStartIndex {
          return index..<self.index(after: matchEnd)
        } else if index == startIndex {
          return nil
        }

        formIndex(before: &index)
        other.formIndex(before: &otherIndex)
      } while try areEquivalent(self[index], other[otherIndex])

      searchEnd = matchEnd
    }

    return nil
  }
}

extension BidirectionalCollection where Element: Equatable {
  /// Returns the last index range where this collection contains the same
  /// elements as another collection in the same order.
  ///
  ///     let string = "foo, bar, foo, bar"
  ///     if let range = string.lastRange(of: "foo", by: ==) {
  ///         print(string[..<range.lowerBound]) // "foo, bar, "
  ///         print(string[range])               // "foo"
  ///         print(string[range.upperBound...]) // ", bar"
  ///     }
  ///
  /// - Parameter other: The collection to search for.
  /// - Returns: The last index range `r` such that `self[r]` equals `other`
  ///   according to `areEquivalent`.
  ///
  /// - Complexity: O(*n \* m*), where *n* is the length of this collection
  ///   and *m* is the length of the collection being searched for.
  @inlinable
  public func lastRange<Other: BidirectionalCollection>(
    of other: Other
  ) -> Range<Index>? where Other.Element == Element {
    lastRange(of: other, by: ==)
  }
}
