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
  /// Groups up elements of `self` into a new Dictionary,
  /// whose values are Arrays of grouped elements,
  /// each keyed by the group key returned by the given closure.
  /// - Parameters:
  ///   - keyForValue: A closure that returns a key for each element in
  ///     `self`.
  /// - Returns: A dictionary containing grouped elements of self, keyed by
  ///     the keys derived by the `keyForValue` closure.
  @inlinable
  public func grouped<GroupKey>(by keyForValue: (Element) throws -> GroupKey) rethrows -> [GroupKey: [Element]] {
    try Dictionary(grouping: self, by: keyForValue)
  }
}
