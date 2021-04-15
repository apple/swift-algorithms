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
  /// - Parameters:
  ///    - predicate: A closure which determines if the element should be
  ///                 omitted from the resulting slice.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  ///
  @inlinable public func trimming(while predicate: (Element) throws -> Bool) rethrows -> SubSequence
  {
    let start = try endOfPrefix(while: predicate)
    let end = try self[start...].startOfSuffix(while: predicate)
    return self[start..<end]
  }
}
