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
// trimmingPrefix(while:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns a `SubSequence` formed by discarding all elements at the start of
  /// the collection which satisfy the given predicate.
  ///
  /// This example uses `trimmingPrefix(while:)` to get a substring without the
  /// white space at the beginning of the string:
  ///
  ///     let myString = "  hello, world  "
  ///     print(myString.trimmingPrefix(while: \.isWhitespace)) // "hello, world  "
  ///
  /// - Parameter predicate: A closure which determines if the element should be
  ///   omitted from the resulting slice.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  ///
  @inlinable
  public func trimmingPrefix(
    while predicate: (Element) throws -> Bool
  ) rethrows -> SubSequence {
    let start = try endOfPrefix(while: predicate)
    return self[start...]
  }
}

//===----------------------------------------------------------------------===//
// trimPrefix(while:)
//===----------------------------------------------------------------------===//

extension Collection where Self: RangeReplaceableCollection {
  /// Mutates a `Collection` by discarding all elements at the start of it which
  /// satisfy the given predicate.
  ///
  /// This example uses `trimPrefix(while:)` to remove the white space at the
  /// beginning of the string:
  ///
  ///     let myString = "  hello, world  "
  ///     myString.trimPrefix(while: \.isWhitespace)
  ///     print(myString) // "hello, world  "
  ///
  /// - Parameter predicate: A closure which determines if the element should be
  ///   removed from the string.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  ///
  @inlinable
  @_disfavoredOverload
  public mutating func trimPrefix(
    while predicate: (Element) throws -> Bool
  ) rethrows {
    let end = try endOfPrefix(while: predicate)
    removeSubrange(startIndex..<end)
  }
}

extension Collection where Self == Self.SubSequence {
  /// Mutates a `Collection` by discarding all elements at the start of it which
  /// satisfy the given predicate.
  ///
  /// This example uses `trimPrefix(while:)` to remove the white space at the
  /// beginning of the string:
  ///
  ///     let myString = "  hello, world  "
  ///     myString.trimPrefix(while: \.isWhitespace)
  ///     print(myString) // "hello, world  "
  ///
  /// - Parameters predicate: A closure which determines if the element should
  ///   be removed from the string.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  ///
  @inlinable
  public mutating func trimPrefix(
    while predicate: (Element) throws -> Bool
  ) rethrows {
    self = try trimmingPrefix(while: predicate)
  }
}

//===----------------------------------------------------------------------===//
// trimming(while:) / trimmingSuffix(while:)
//===----------------------------------------------------------------------===//

extension BidirectionalCollection {
  /// Returns a `SubSequence` formed by discarding all elements at the start and
  /// end of the collection which satisfy the given predicate.
  ///
  /// This example uses `trimming(while:)` to get a substring without the white
  /// space at the beginning and end of the string:
  ///
  ///     let myString = "  hello, world  "
  ///     print(myString.trimming(while: \.isWhitespace)) // "hello, world"
  ///
  /// - Parameter predicate: A closure which determines if the element should be
  ///   omitted from the resulting slice.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  ///
  @inlinable
  public func trimming(
    while predicate: (Element) throws -> Bool
  ) rethrows -> SubSequence {
    try trimmingPrefix(while: predicate).trimmingSuffix(while: predicate)
  }
  
  /// Returns a `SubSequence` formed by discarding all elements at the end of
  /// the collection which satisfy the given predicate.
  ///
  /// This example uses `trimmingSuffix(while:)` to get a substring without the
  /// white space at the end of the string:
  ///
  ///     let myString = "  hello, world  "
  ///     print(myString.trimmingSuffix(while: \.isWhitespace)) // "  hello, world"
  ///
  /// - Parameter predicate: A closure which determines if the element should be
  ///   omitted from the resulting slice.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  ///
  @inlinable
  public func trimmingSuffix(
    while predicate: (Element) throws -> Bool
  ) rethrows -> SubSequence {
    let end = try startOfSuffix(while: predicate)
    return self[..<end]
  }
}

//===----------------------------------------------------------------------===//
// trim(while:) / trimSuffix(while:)
//===----------------------------------------------------------------------===//

extension BidirectionalCollection where Self: RangeReplaceableCollection {
  /// Mutates a `BidirectionalCollection` by discarding all elements at the
  /// start and at the end of it which satisfy the given predicate.
  ///
  /// This example uses `trim(while:)` to remove the white space at the
  /// beginning of the string:
  ///
  ///     let myString = "  hello, world  "
  ///     myString.trim(while: \.isWhitespace)
  ///     print(myString) // "hello, world"
  ///
  /// - Parameter predicate: A closure which determines if the element should be
  ///   removed from the string.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  ///
  @inlinable
  @_disfavoredOverload
  public mutating func trim(
    while predicate: (Element) throws -> Bool
  ) rethrows {
    try trimSuffix(while: predicate)
    try trimPrefix(while: predicate)
  }
  
  /// Mutates a `BidirectionalCollection` by discarding all elements at the end
  /// of it which satisfy the given predicate.
  ///
  /// This example uses `trimSuffix(while:)` to remove the white space at the
  /// beginning of the string:
  ///
  ///     let myString = "  hello, world  "
  ///     myString.trimSuffix(while: \.isWhitespace)
  ///     print(myString) // "  hello, world"
  ///
  /// - Parameter predicate: A closure which determines if the element should be
  ///   removed from the string.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  ///
  @inlinable
  @_disfavoredOverload
  public mutating func trimSuffix(
    while predicate: (Element) throws -> Bool
  ) rethrows {
    let start = try startOfSuffix(while: predicate)
    removeSubrange(start..<endIndex)
  }
}

extension BidirectionalCollection where Self == Self.SubSequence {
  /// Mutates a `BidirectionalCollection` by discarding all elements at the
  /// start and at the end of it which satisfy the given predicate.
  ///
  /// This example uses `trim(while:)` to remove the white space at the
  /// beginning of the string:
  ///
  ///     let myString = "  hello, world  "
  ///     myString.trim(while: \.isWhitespace)
  ///     print(myString) // "hello, world"
  ///
  /// - Parameter predicate: A closure which determines if the element should be
  ///   removed from the string.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  ///
  @inlinable
  public mutating func trim(
    while predicate: (Element) throws -> Bool
  ) rethrows {
    self = try trimming(while: predicate)
  }

  /// Mutates a `BidirectionalCollection` by discarding all elements at the end
  /// of it which satisfy the given predicate.
  ///
  /// This example uses `trimSuffix(while:)` to remove the white space at the
  /// beginning of the string:
  ///
  ///     let myString = "  hello, world  "
  ///     myString.trimSuffix(while: \.isWhitespace)
  ///     print(myString) // "  hello, world"
  ///
  /// - Parameter predicate: A closure which determines if the element should be
  ///   removed from the string.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  ///
  @inlinable
  public mutating func trimSuffix(
    while predicate: (Element) throws -> Bool
  ) rethrows {
    self = try trimmingSuffix(while: predicate)
  }
}
